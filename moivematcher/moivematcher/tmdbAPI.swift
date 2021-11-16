
import Foundation
import AVFoundation

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

enum MovieEndpoint: Endpoint {
    case Genre(page: String)
    case Actor(page: String)
    case Movie(page: String)
    case MovieDetails(id: String)
    case MovieRecommendations(id: String)
    case MovieCredits(id: String)
    case TopRatedMovie(page: String)
    case ActorDetails(id: Int)
    
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
            case .TopRatedMovie:
                return "/3/movie/top_rated"
            case .MovieRecommendations(let id):
                return "/3/movie/\(id)/recommendations"
            case .MovieDetails(let id):
                return "/3/movie/\(id)"
            case .MovieCredits(let id):
                return "/3/movie/\(id)/credits"
            case .ActorDetails(let id):
                return "/3/person/\(id)"
        }
    }
    
    var parameters: [String : String] {
        var parameters = [String : String]()
        parameters["api_key"] = "b9d865c7ae2da5f3874022df4c9b4603"
        
        switch self {
        case .Actor(let page), .Movie(let page), .Genre(let page), .TopRatedMovie(let page):
            parameters["page"] = page
            return parameters
        case .MovieDetails:
            parameters["append_to_response"] = "credits,videos,recommendations,similar"
            return parameters
        case .ActorDetails:
            parameters["append_to_response"] = "movie_credits"
            return parameters
        case .MovieRecommendations, .MovieCredits:
            return parameters
        }
    }
}

final class MovieApiClient: ApiClient, HttpClient {
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
        let endpoint = MovieEndpoint.Genre(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Genre]? in
            guard let genres = json["genres"] as? [[String:AnyObject]] else {
                return nil
            }
            return genres.flatMap {
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
        let endpoint = MovieEndpoint.Actor(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Actor]? in
            guard let popularActors = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return popularActors.flatMap {
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
        let endpoint = MovieEndpoint.Movie(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Movie]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            let movies = popularMovies.flatMap { (movie) -> Movie? in
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
    
    func fetchMoviesID(page: Int, completion: @escaping (APIResult<[Int]>) -> Void) {
        let endpoint = MovieEndpoint.Movie(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Int]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            let movies = popularMovies.flatMap { (movie) -> Int? in
                do {
                    return try Movie(JSON: movie)?.hashValue
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
    
    func fetchTopRatedMoviesID(page: Int, completion: @escaping (APIResult<[Int]>) -> Void) {
        let endpoint = MovieEndpoint.TopRatedMovie(page: String(page))
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Int]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            let movies = popularMovies.flatMap { (movie) -> Int? in
                do {
                    return try Movie(JSON: movie)?.hashValue
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
    
    func fetchMovieDetails(movieId: String, completion: @escaping (APIResult<MovieWithGenres>) -> Void) {
        let endpoint = MovieEndpoint.MovieDetails(id: movieId)
        let request = endpoint.request
        fetch(request: request, parse: { (json) -> MovieWithGenres? in
            do {
                return try MovieWithGenres(JSON: json)
            } catch (let error){
                print(error)
            }
            return nil
        }, completion: completion)
    }
    
    func fetchMoviesRecommendations(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void) {
        
        let endpoint = MovieEndpoint.MovieRecommendations(id: movieId)
        let request =  endpoint.request
        
        fetch(request: request, parse: { (json) -> [Movie]? in
            guard let popularMovies = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            
            let movies =  popularMovies.flatMap { (movie) -> Movie? in
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
    
    func fetchActorDetails(actor: Actor, completion:  @escaping () -> Void) {
        let endpoint = MovieEndpoint.ActorDetails(id: actor.id)
        let request = endpoint.request
        fetch(request: request, parse: { (json) -> [Actor]? in
            do {
                actor.biography = json["biography"] as? String ?? ""
                let movieCredits = json["movie_credits"] as? [String: AnyObject] ?? [:]
                let tmdbMovies = movieCredits["cast"] as? [[String: AnyObject]] ?? []
                actor.relatedMovies = self.fetchRelatedMovies(from: tmdbMovies)
                actor.fullyDetailed = true
                print(json)
                print(actor.biography)
                DispatchQueue.main.async {
                    completion()
                }
            } catch (let error){
                print(error)
            }
            return nil
        }) { result in
        }
    }
    
    func fetchRelatedMovies(from response: [[String: AnyObject]], filter: ((MovieWithGenres) -> Bool)? = nil) -> [MovieWithGenres] {
        var items: [MovieWithGenres] = []

        for tmdbMovie in response {
            // Ensure all required values are available
            do {
                let item = try MovieWithGenres(JSON: tmdbMovie)!
                    items.append(item)
            } catch {
                print(error)
            }
        }
        return items
    }
}
