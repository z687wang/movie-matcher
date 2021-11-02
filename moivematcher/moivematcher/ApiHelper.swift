//
//  ApiHelper.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation
protocol ApiClient {
    func fetchGenres(page: Int, completion: @escaping (APIResult<[Genre]>)-> Void)
    func fetchActors(page: Int, completion: @escaping (APIResult<[Actor]>)-> Void)
    func fetchMovies(page: Int, completion: @escaping (APIResult<[Movie]>)-> Void)
    func fetchMoviesRecommendations(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void)
    func fetchMovieCredits(endpoint: Endpoint, completion: @escaping (APIResult<[Credit]>)-> Void)
}
