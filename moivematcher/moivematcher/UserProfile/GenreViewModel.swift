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
            print("length is 2")
            length = 2
        }
        else {
            length = genresLikedArray.count
        }
        
        if genresLikedArray.count > 0 {
            genres = Array(genresLikedArray[...length])
        }
        else {
            print("less than 3 movies")
            genres = ["Animation"]
        }
    }
}
