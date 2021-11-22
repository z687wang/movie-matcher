//
//  ApiHelper.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation
protocol ApiClient {
    func fetchGenres(page: Int, completion: @escaping (APIResult<[Genre]>) -> Void)
    func fetchMovies(page: Int, completion: @escaping (APIResult<[Movie]>) -> Void)
    func fetchMoviesID(page: Int, completion: @escaping (APIResult<[Int]>) -> Void)
    func fetchMoviesRecommendations(movieId: String, completion: @escaping (APIResult<[Movie]>) -> Void)
    func fetchMovieDetails(movieId: String, completion: @escaping (APIResult<MovieWithGenres>) -> Void)
    func fetchActors(page: Int, completion: @escaping (APIResult<[Actor]>) -> Void)
    func fetchActorDetails(actor: Actor, completion: @escaping () -> Void)
}
