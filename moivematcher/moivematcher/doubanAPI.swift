//
//  DoubanMovieAPI.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-10.
//

import Foundation


protocol DoubanAPIClient {
    func getDoubanMovieIDFromIMDBID(imdb_id: String, completion: @escaping (APIResult<[Genre]>)-> Void)
    func getDoubanMovieDetailFromDoubanID(douban_id: String, completion: @escaping (APIResult<String>) ->Void)
}

enum DouBanEndpoint: Endpoint {
    case Genre(page: String)
    case Actor(page: String)
    case Movie(page: String)
    case MovieDetails(id: String)
    case MovieRecommendations(id: String)
    case MovieCredits(id: String)
    
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
            case .MovieDetails(let id):
                return "/3/movie/\(id)"
            case .MovieCredits(let id):
                return "/3/movie/\(id)/credits"
        }
    }
    
    var parameters: [String : String] {
        var parameters = [String : String]()
        parameters["api_key"] = ""
        
        switch self {
        case .Actor(let page), .Movie(let page), .Genre(let page):
            parameters["page"] = page
            return parameters
        case .MovieDetails:
            parameters["append_to_response"] = "credits,videos,recommendations,similar"
            return parameters
        case .MovieRecommendations, .MovieCredits:
            return parameters
        }
    }
}

final class MyDoubanAPIClient: DoubanAPIClient {
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
    
    func getDoubanMovieIDFromIMDBID(imdb_id: String, completion: @escaping (APIResult<[Genre]>) -> Void) {
        
    }
    
    func getDoubanMovieDetailFromDoubanID(douban_id: String, completion: @escaping (APIResult<String>) -> Void) {
        <#code#>
    }
}
