//
//  RecommendDataLoader.swift
//  moivematcher
//
//  Created by Bohan on 11/14/21.
//

import Foundation

struct RecommendDataLoader{
    
    func loadMovies() -> [Movie] {
        if let movieData = loadFile(from: "movieDB", withExtension: ".csv"){
            let movies = movieData.components(separatedBy: "\n")
            return createMovies(from: movies)
        }
        return [Movie]()
    }
    
    func generateTmdbId(outputRec: [Int64]) -> [Int64]{
        var res: [Int64] = []
        if let linkData = loadFile(from: "links", withExtension: ".csv"){
            
            let links = linkData.components(separatedBy: "\n")
            for i in outputRec{
                for j in links{
                    let info = j.components(separatedBy: ",")
                    if(Int64(info[0]) == i){
                        var tmbd = info[2].split(separator: "\r")[0]
                        res.append(Int64(tmbd)!)
                    }
                }
            }
        }
        return res
    }
    
    func loadFile(from filePath: String, withExtension fileExtension: String) -> String? {
        if let fileUrl = Bundle.main.url(forResource: filePath, withExtension: fileExtension) {
            return try? String(contentsOf: fileUrl)
        }
        return nil
    }

    func createMovies(from movies: [String]) -> [Movie] {
        var movieList: [Movie] = []
        
        for (_, movieString) in movies.enumerated() {
            let movieAttributes = movieString.components(separatedBy: ",")
            if let movieId = Int(movieAttributes[0]) {
                let movie = Movie(title: movieAttributes[1], id: movieId, genreIds: extractGenres(from: movieAttributes[3]))
                movieList.append(movie)
            }
        }
        return movieList
    }

    func extractGenres(from movieGenres: String) -> [Int] {
        var res: [Int] = []
        let array = movieGenres.components(separatedBy: " ")
        if array.contains(""){
            res.append(Int(movieGenres) ?? 0)
        }else{
            res = array.map { Int($0)!}
        }
        return res
    }

}
