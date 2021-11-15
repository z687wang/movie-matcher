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
    }

    func rateCurrentMovie(id: Int, rating: Int) {
        recommendationModel.rate(id: id, rating: Double(rating))
    }
    
    func recommendMovies() -> [Int64] {
        let movies = recommendationModel.recommendMovies(numberOfItems: 14)
        return movies
    }
    
    func getMovieData() {
        backgroundImage = nil
    }
}

