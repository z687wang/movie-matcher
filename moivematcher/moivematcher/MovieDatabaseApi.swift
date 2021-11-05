//
//  File.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String] { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
        }
        return queryItems
    }
    
    var request: URLRequest {
        let components = NSURLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryItems // the URL is percent encoded here
        
        let url = components.url!
        return URLRequest(url: url)
    }
}

enum MovieNightEndpoint: Endpoint {
    case Genre(page: String)
    case Actor(page: String)
    case Movie(page: String)
    case MovieRecommendations(id: String)
    case MovieCredits(id: String)
    case MoviePoster(id: String)
    
    var baseURL: String {
        return "https://api.themoviedb.org"
    }
    var path: String {
        switch self {
            case .Genre:
                return "/3/genre/movie/list"
            case .Actor:
                return "/3/person/popular"
            case .Movie:
                return "/3/movie/popular"
            case .MovieRecommendations(let id):
                return "/3/movie/\(id)/recommendations"
            case .MovieCredits(let id):
                return "/3/movie/\(id)/credits"
            case .MoviePoster(let id):
                return "/3/movie/\(id)/images"
        }
    }
    
    var parameters: [String : String] {
        var parameters = [String : String]()
        parameters["api_key"] = "b9d865c7ae2da5f3874022df4c9b4603"
        
        switch self {
        case .Actor(let page), .Movie(let page), .Genre(let page):
            parameters["page"] = page
            return parameters
        case .MovieRecommendations, .MovieCredits:
            return parameters
        case .MoviePoster:
            return parameters
        }
    }
}

final class MovieNightApiClient: ApiClient, HttpClient {
    
    var configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func fetchGenres(page: Int, completion: @escaping (APIResult<[Genre]>) -> Void) {
        let endpoint = MovieNightEndpoint.Genre(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Genre]? in
            guard let genres = json["genres"] as? [[String:AnyObject]] else {
                return nil
            }
            return genres.compactMap {
                do {
                    return try Genre(JSON: $0)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
        }, completion: completion)
    }
    
    func fetchActors(page: Int, completion: @escaping (APIResult<[Actor]>) -> Void) {
        let endpoint = MovieNightEndpoint.Actor(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Actor]? in
            guard let popularActors = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return popularActors.compactMap {
                do {
                    return try Actor(JSON: $0)
                } catch (let error){
                    print(error)
                }
                return nil
            }
        }, completion: completion)
    }
    
    func fetchMovies(page: Int, completion: @escaping (APIResult<[Movie]>) -> Void) {
        let endpoint = MovieNightEndpoint.Movie(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Movie]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            let movies = popularMovies.compactMap { (movie) -> Movie? in
                do {
                    return try Movie(JSON: movie)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            
            if movies.isEmpty {
                return nil
            } else {
                return movies
            }
        }, completion: completion)
    }
    
    func fetchMoviesPosters(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void) {
        
        let endpoint = MovieNightEndpoint.MoviePoster(id: movieId)
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Movie]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let movies =  popularMovies.compactMap { (movie) -> Movie? in
                do {
                    return try Movie(JSON: movie)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            if movies.isEmpty {
                return nil
            } else {
                return movies
            }
        }, completion: completion)
    }
    
    func fetchMoviesRecommendations(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void) {
        
        let endpoint = MovieNightEndpoint.MovieRecommendations(id: movieId)
        let request =  endpoint.request
        
        fetch(request: request, parse: { (json) -> [Movie]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let movies =  popularMovies.compactMap { (movie) -> Movie? in
                do {
                    return try Movie(JSON: movie)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            if movies.isEmpty {
                return nil
            } else {
                return movies
            }
        }, completion: completion)
    }

}
