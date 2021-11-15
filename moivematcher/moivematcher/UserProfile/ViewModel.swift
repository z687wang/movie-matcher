//
//  GenreViewModel.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import Foundation

class GenreViewModel: ObservableObject {
    
    @Published var genres = [String]()

    init() {
        var length = 0
        
        if genresLikedArray.count >= 3 {
            length = 2
        }
        else {
            length = genresLikedArray.count
        }
        
        if actorsLikedArray.count > 0 {
            self.genres = Array(Array(Set(genresLikedArray.sortByNumberOfOccurences()))[...length])
//            print(Array(Set(genresLikedArray.sortByNumberOfOccurences())))
        }
    }
}

class ActorViewModel: ObservableObject {
    
    @Published var actors = [Actor]()

    init() {
        var length = 0
        
        if actorsLikedArray.count >= 3 {
            length = 2
        }
        else {
            length = actorsLikedArray.count
        }
        
        if actorsLikedArray.count > 0 {
            self.actors = Array(Array(Set(actorsLikedArray.sortByNumberOfOccurences()))[...length])
//            print(Array(Set(genresLikedArray.sortByNumberOfOccurences())))
        }
    }
}
