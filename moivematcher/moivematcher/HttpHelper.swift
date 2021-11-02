//
//  HttpHelper.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation
import UIKit

public let TREnetworkingErrorDomain = "com.tassia.MovieNight.NetworkingError"
public let JsonKeyOrElementInvalid: Int = 20
public let JsonIsNill: Int = 21
public let JsonConversionInvalid: Int = 22
typealias JSON = [String: AnyObject]


enum APIResult<T> {
    case success((resource: T, hasPage: Bool))
    case failure(Error)
}

protocol HttpClient {
    var session: URLSession { get }
    var configuration: URLSessionConfiguration { get }
    
    func jsonTask(with request: URLRequest, completion: @escaping (JSON?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask
    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T? , completion: @escaping (APIResult<T>) -> Void)
}

extension HttpClient {
    func jsonTask(with request: URLRequest, completion: @escaping (JSON?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : AnyObject]
                        completion(json as JSON?, nil, nil)
                    } catch(let error) {
                        completion(nil , nil , error)
                        print("json error: \(error.localizedDescription)")
                    }
                default:
                    completion(nil, HTTPResponse, nil)
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled, \(String(describing: request.url))")
                }
            }
        }
        return task
    }

    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        var hasNextPage = true
        let task = jsonTask(with: request) { (json, reponse, apiError) in
            
            DispatchQueue.main.async {
                
                if let apiError = apiError {
                    completion(APIResult.failure(apiError))
                    return
                }
                
                guard let json = json else {
                    let error = NSError(domain: TREnetworkingErrorDomain, code: JsonIsNill, userInfo: nil)
                    completion(APIResult.failure(error))
                    return
                }
                
                // Hard to read - try to improve it
                if let result = parse(json) {
                    if let page = json["page"] as? Int, let totalPages = json["total_pages"] as? Int {
                        if page != totalPages {
                            completion(APIResult.success((result,hasNextPage)))
                        } else {
                            hasNextPage = false
                            completion(APIResult.success((result,hasNextPage)))
                        }
                    } else {
                        hasNextPage = false
                        completion(APIResult.success((result,hasNextPage)))
                    }
                } else {
                    let error = NSError(domain: TREnetworkingErrorDomain, code: JsonConversionInvalid, userInfo: nil)
                    completion(APIResult.failure(error))
                }
            }
        }
        task.resume()
    }
}
