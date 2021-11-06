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
    case MovieVideos(id: String)
    
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
            case .MovieVideos(let id):
                return "/3/movie/\(id)/videos"
        }
    }
    
    var parameters: [String : String] {
        var parameters = [String : String]()
        parameters["api_key"] = "b9d865c7ae2da5f3874022df4c9b4603"
        
        switch self {
        case .Actor(let page), .Movie(let page), .Genre(let page):
            parameters["page"] = page
            return parameters
        case .MovieRecommendations, .MovieCredits, .MovieVideos:
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
    
    // Fetch popular movies
    func fetchMovies(page: Int, completion: @escaping (APIResult<[Movie]>) -> Void) {
        let endpoint = MovieNightEndpoint.Movie(page: String(page))
        let request = endpoint.request
//        print(request.url)
        
        fetch(request: request, parse: { (json) -> [Movie]? in
//            print(json)
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
        
//    Fecth leading actors of the movie
    func fetchMovieActors(movieId: String, completion: @escaping (APIResult<[PersonOfMovie]>) -> Void) {
        
        let endpoint = MovieNightEndpoint.MovieCredits(id: movieId)
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [PersonOfMovie]? in
            print(json["cast"])
            guard let movieCredits = json["cast"] as? [[String:AnyObject]], let movieId = json["id"] as? Int else {
                return nil
            }
            
            let actors = movieCredits.compactMap { (acteur) -> PersonOfMovie? in
                do {
                    return try PersonOfMovie(JSON: acteur, movieId: movieId)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            if actors.count < 5 {
                return actors
            }
            else {
                return Array(actors.prefix(upTo: 5))
            }
            
            
//            if actors.isEmpty {
//                print(3)
//                return nil
//            } else {
//                return actors
//            }
        }, completion: completion)
    }
    
    //    Fecth leading actors of the movie
    func fetchMovieDirector(movieId: String, completion: @escaping (APIResult<Crew>) -> Void) {
        
        let endpoint = MovieNightEndpoint.MovieCredits(id: movieId)
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> Crew? in
            print(json["crew"])
            guard let movieCredits = json["crew"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let crews = movieCredits.compactMap { (crew) -> Crew? in
                do {
                    return try Crew(JSON: crew)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            var director = crews[0]
            
            for crew in crews {
                if crew.job == "Director" {
                    director = crew
                }
            }
            
            return director
            
//            if actors.count < 5 {
//                return actors
//            }
//            else {
//                return Array(actors.prefix(upTo: 5))
//            }
            
        }, completion: completion)
    }
    
    //    Fecth leading actors of the movie
    func fetchVideo(movieId: String, completion: @escaping (APIResult<Video>) -> Void) {
        
        let endpoint = MovieNightEndpoint.MovieVideos(id: movieId)
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> Video? in
            print(json["results"])
            guard let results = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let videos = results.compactMap { (video) -> Video? in
                do {
                    return try Video(JSON: video)
                } catch (let error){
                    print(error)
                }
                return nil
            }
            
            return nil
            
//            if actors.count < 5 {
//                return actors
//            }
//            else {
//                return Array(actors.prefix(upTo: 5))
//            }
            
        }, completion: completion)
    }

}
