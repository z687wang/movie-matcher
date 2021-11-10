//
//  URLSession+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 1/28/19.
//  Copyright © 2019 Carolco LLC. All rights reserved.
//

import Foundation

struct URLSessionError: LocalizedError {
    public let message: String
    public let code: Int
}

extension URLSession {
    
    /// Makes a synchronous request (locking the calling thread) with the given arguments
    ///
    /// - Parameter url: The URL for the request.
    /// - Parameter method: The HTTP request method.
    /// - Parameter body: The data sent as the message body of a request, such as for an HTTP POST request.
    /// - Parameter headers: A dictionary containing the request’s HTTP header fields.
    /// - Parameter attempts: The number of times that the request should be attempted. Set a number higher than 1 to enable retries. The request will be attempted more than once only if it fails do to a timeout error.
    /// - Parameter timeoutInterval: The timeout interval for the request.
    func syncRequest(url: String, method: String = "GET", body: Data? = nil, headers: [String: String]? = [:], attempts: Int = 1, retryOnTimeoutsOnly: Bool = true, timeoutInterval: Double = 20) -> (data: Data?, response: URLResponse?, error: Error?) {
        var result: (data: Data?, response: URLResponse?, error: Error?)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        if body != nil {
            request.httpBody = body
        }
        
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        var remainingAttempts = attempts
        
        repeat {
            remainingAttempts -= 1
            let semaphore = DispatchSemaphore(value: 0) // Using semaphore to make request synchronous
            let task = dataTask(with: request) { data, response, error in
                result = (data, response, error)
                semaphore.signal()
            }
            task.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        } while remainingAttempts > 0 && (isTimedOutError(result.error) || (!retryOnTimeoutsOnly && !isSuccessfulResponse(result.response)))
        
        return result
    }
    
    /// Requests a JSON object making a synchronous request (locking the calling thread) with the given arguments.
    /// See `syncRequest()`.
    func syncRequestJSON(url: String, method: String = "GET", body: Data? = nil, headers: [String: String]? = [:], attempts: Int = 1, retryOnTimeoutsOnly: Bool = true, timeoutInterval: Double = 20) -> (json: [String: AnyObject], error: URLSessionError?) {
        
        var json: [String: AnyObject] = [:]
        var error: URLSessionError? = nil

        // Make request
        let (responseData, urlResponse, _) = syncRequest(url: url, method: method, body: body, headers: headers, attempts: attempts, retryOnTimeoutsOnly: retryOnTimeoutsOnly, timeoutInterval: timeoutInterval)
        guard let data = responseData else {
            return (json, error)
        }

        // Get response json object
        if let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
            json = obj
        }
        
        // Capture error if status code not OK (not 200)
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            error = URLSessionError(message: msg, code: httpResponse.statusCode)
        }
        
        return (json, error)
    }
    
    private func isTimedOutError(_ error: Error?) -> Bool {
        var timedOut = false

        if let error = error, (error as NSError).code == NSURLErrorTimedOut {
            timedOut = true
        }
        
        return timedOut
    }
    
    private func isSuccessfulResponse(_ response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }

        return true
    }
}
