//
//  MovieMatcherModel.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation
import UIKit
import SwiftDate
import Nuke

//Model

enum ErrorApi : Error {
    case jsonInvalidKeyOrElement(String)
}

protocol JSONDecodable {
    init?(JSON: [String: AnyObject]) throws
}

struct Crew: JSONDecodable {
    
    init?(JSON: [String : AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let job = JSON["job"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -job-")
        }
        self.name = name
        self.job = job
    }
    
    
    var name: String
    var job: String
    
    init(name: String, job: String) {
        self.name = name
        self.job = job
    }
    
}

struct Actor: JSONDecodable, Equatable {
    var name: String
    var id: Int
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }

    
    init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        self.name = name
        self.id = id
    }
    
    static func ==(lhs: Actor, rhs: Actor) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PersonOfMovie {
    var movieId: Int
    var actor: Actor
    
    init?(JSON: [String: AnyObject], movieId: Int) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")        }
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        
        self.actor = Actor(name: name, id: id)
        self.movieId = movieId
    }
}

struct Video {
    var name: String
    var key: String
    var site: String
    
    init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let key = JSON["key"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -key-")
        }
        guard let site = JSON["site"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -site-")
        }
        self.name = name
        self.key = key
        self.site = site
    }
}

struct Genre: JSONDecodable, Equatable {
    var name: String
    var id: Int
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }

    
    init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        self.name = name
        self.id = id
    }
    
    static func ==(lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Movie : JSONDecodable, Hashable, Equatable {
    var title: String
    var releaseDate: String?
    var voteAverage: Int?
    var genreIds: [Int]?
    var id: Int
    var hashValue : Int { return self.id }
    
    init(title: String, id: Int, genreIds: [Int]?) {
        self.title = title
        self.id = id
        self.genreIds = genreIds
    }
    
    init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["title"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
           throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        guard let genreIds = JSON["genre_ids"] as? [Int] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -genresIds-")
        }
        guard let releaseDate = JSON["release_date"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -release_date-")
        }
        self.title = name
        self.id = id
        self.genreIds = genreIds
        self.releaseDate = releaseDate
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}

enum MediaItemImageType {
    case portrait
    case backdrop
}

class MovieWithGenres : JSONDecodable, Identifiable, Hashable, Equatable {
    var title: String
    var releaseDate: String?
    var releaseDateObj: Date?
    var voteAverage: Double?
    var voteCount: Int?
    var genres: [Genre]?
    var id: Int
    var hashValue : Int { return self.id }
    var poster_path: String?
    var bg_path: String?
    var original_language: String?
    var overview: String?
    var revenue: Int?
    
    var posterURL: URL?
    var bgURL: URL?
    var popularity: Double?
    var adult: Int?
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var degree: Double = 0.0
    var genresStr: String = ""
    
    init(title: String, id: Int, genreIds: [Genre]?) {
        self.title = title
        self.id = id
        self.genres = genreIds
    }
    
    required init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["title"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
           throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        guard let genres = JSON["genres"] as? [[String:AnyObject]] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -genresIds-")
        }
        guard let releaseDate = JSON["release_date"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -release_date-")
        }
        guard let voteAvg = JSON["vote_average"] as? Double else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -vote_average-")
        }
        guard let voteCount = JSON["vote_count"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -vote_count-")
        }
        guard let pop = JSON["popularity"] as? Double else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -popularity-")
        }
        guard let adult = JSON["adult"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -adult-")
        }
        guard let poster_path = JSON["poster_path"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -poster_path-")
        }
        guard let langue = JSON["original_language"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -original_language-")
        }
        guard let overview = JSON["overview"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -overview-")
        }
        guard let bg_path = JSON["backdrop_path"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -backdrop_path-")
        }
        guard let revenue = JSON["revenue"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -revenue-")
        }
        self.title = name
        self.id = id
        self.genres = genres.flatMap {
            do {
                return try Genre(JSON: $0)
            } catch (let error){
                print(error)
            }
            return nil
        }
        let genresArray = self.genres.map{ $0.map {$0.name }}
        self.genresStr = genresArray?.compactMap { $0 }.joined(separator: ", ") ?? ""
        self.releaseDate = releaseDate
        self.releaseDateObj = Date(self.releaseDate ?? "")
        self.voteAverage = voteAvg
        self.voteCount = voteCount
        self.popularity = pop
        self.adult = adult
        self.bg_path = bg_path
        self.poster_path = poster_path
        self.posterURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.poster_path!)!
        self.bgURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.bg_path!)!
        self.original_language = langue
        self.overview = overview
        self.revenue = revenue
    }
    
    static func == (lhs: MovieWithGenres, rhs: MovieWithGenres) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getGenres() -> String {
        return self.genresStr
    }
    
    private var _portraitAverageColor: UIColor?
    private var _backdropAverageColor: UIColor?
    
    func averageColor(of imageType: MediaItemImageType, completion: @escaping (UIColor?) -> Void) {
        // Return cached `averageColor` result if exists
        if imageType == .portrait && _portraitAverageColor != nil {
            completion(_portraitAverageColor)
            return
        }
        if imageType == .backdrop && _backdropAverageColor != nil {
            completion(_backdropAverageColor)
            return
        }
        
        let imageUrl = imageType == .backdrop ? self.bgURL : self.posterURL
//        guard let imageUrl = URL(string: imagePath!) else {
//            completion(nil)
//            return
//        }
        
        ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
            switch result {
            case let .success(response):
                let averageColor = response.image.averageColor?.lighter()
                
                // Cache result
                if imageType == .portrait {
                    self?._portraitAverageColor = averageColor
                }
                else if imageType == .backdrop {
                    self?._backdropAverageColor = averageColor
                }
                
                completion(averageColor)
            case .failure(_): completion(nil)
            }
        }
    }
}


// MARK: - Image
struct Image: Codable {
    init?(JSON: [String : AnyObject]) throws {
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        guard let backdrops = JSON["backdrop"] as? [Backdrop] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -backdrops-")
        }
        guard let posters = JSON["posters"] as? [Backdrop] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -backdrops-")
        }
        guard let logos = JSON["logos"] as? [Backdrop] else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -logos-")
        }
        self.id = id
        self.backdrops = backdrops
        self.posters = posters
        self.logos = logos
    }
    let id: Int
    let backdrops, posters, logos: [Backdrop]
}

// MARK: - Backdrop
struct Backdrop: Codable {
    let aspectRatio: Double
    let filePath: String
    let height: Int
    let iso639_1: String?
    let voteAverage, voteCount, width: Int

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case height
        case iso639_1 = "iso_639_1"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case width
    }
}

