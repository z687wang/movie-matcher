//
//  RecommendatinModel.swift
//  moivematcher
//
//  Created by Bohan on 11/7/21.
//

import Foundation
import CoreML

struct RecommendationModel {
        
    var ratings: [String: Double] {
        didSet {
            UserDefaults.standard.set(ratings, forKey: "ratings")
        }
    }
    
    var movies: [Movie]
    var recommenderEngine: MovieRecommenderModel
    
    init(ratings: [Int64: Double], movies: [Movie]) {
        self.ratings = UserDefaults.standard.dictionary(forKey: "ratings") as? [String: Double] ?? [String: Double]()
        print("Loaded ratings from UserDefaults: \(self.ratings)")
        self.movies = movies
        self.recommenderEngine = try! MovieRecommenderModel(configuration: MLModelConfiguration())
    }
    
    mutating func rate(id: Int, rating: Double) {
        ratings[String(id)] = rating
        print(ratings)
    }
    
    func ratingFor(movie: Movie) -> Double? {
        ratings[String(movie.id)]
    }
    
    func recommendMovies(numberOfItems: Int) -> [Int64] {
        
        let recommenderInput = MovieRecommenderModelInput(items: createRecommendationInput(from: ratings), k: Int64(numberOfItems))
        
        print(ratings)
        
        let output = try? recommenderEngine.prediction(input: recommenderInput)
        
        return RecommendDataLoader().generateTmdbId(outputRec: output?.recommendations ?? [0])
    }
    
    private func createRecommendationInput(from ratings: [String: Double]) -> [Int64: Double] {
        var newDictionary = [Int64: Double]()
        
        ratings.forEach { (key, value) in
            newDictionary[Int64(key)!] = value
        }
        
        return newDictionary
    }
    
}


