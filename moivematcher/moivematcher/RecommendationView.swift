//
//  RecommendationView.swift
//  moivematcher
//
//  Created by Bohan on 11/7/21.
//

import Foundation
import SwiftUI
import Combine

class RecommendationViewModel: ObservableObject {
    var recommendationModel: RecommendationModel
    
    var ratings: [String: Double] {
        get {
            recommendationModel.ratings
        }
    }
    
    @Published var currentMovie: Movie? {
        didSet {
            if currentMovie?.id != nil {
                getMovieData()
            }
        }
    }
    
    @Published var recommendedMovie: Movie? {
        didSet {
            if currentMovie?.id != nil {
                getMovieData()
            }
        }
    }
    
    @Published private(set) var backgroundImage: UIImage?
    @Published private(set) var recommendedMovieImage: UIImage?
    
    init() {
        recommendationModel = RecommendationModel(ratings: [:], movies: RecommendDataLoader().loadMovies())
//        currentMovie = recommendationModel.movies.randomElement()
    }
    
//    func getMovie(fromId id: Int64) -> Movie? {
//        recommendationModel.movies.first { $0.id == id }
//    }
//
//    func nextMovie() {
//        currentMovie = recommendationModel.movies.randomElement()
//    }
    
    func rateCurrentMovie(movie: Movie, rating: Int) {
        let movieToRate = movie
        recommendationModel.rate(movie: movieToRate, rating: Double(rating))
    }
    
    func recommendMovies() -> [Movie] {
        let movies = recommendationModel.recommendMovies(numberOfItems: 10)
        print(movies)
        return movies
    }
    
    func getMovieData() {
        backgroundImage = nil
    }
    
    
}

