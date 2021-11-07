//
//  ApiHelper.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation
protocol ApiClient {
//    func fetchGenres(page: Int, completion: @escaping (APIResult<[Genre]>)-> Void)
    func fetchMovies(page: Int, completion: @escaping (APIResult<[Movie]>)-> Void)
//    func fetchMoviesRecommendations(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void)
    func fetchMovieActors(movieId: String, completion: @escaping (APIResult<[PersonOfMovie]>) -> Void)
    func fetchMovieDirector(movieId: String, completion: @escaping (APIResult<Crew>) -> Void)
}
