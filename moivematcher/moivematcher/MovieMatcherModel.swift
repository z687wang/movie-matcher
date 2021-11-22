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

class YouTubeItem: NSObject {

    var tmdbId: String = ""
    var youtubeId: String = ""
    var title: String = ""
    var type: String = ""
    
    // Thumbnail path construction based on: https://stackoverflow.com/a/2068371/1792699
    lazy var thumbnailPathHigh: String = {
        return "https://img.youtube.com/vi/\(youtubeId)/maxresdefault.jpg"
    }()
    
    lazy var thumbnailPathMedium: String = {
        return "https://i.ytimg.com/vi/\(youtubeId)/mqdefault.jpg"
    }()
}

struct Crew: JSONDecodable, Hashable {
    
    init?(JSON: [String : AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let job = JSON["job"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -job-")
        }
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        let knowForDepartment = JSON["known_for_department"] as? String
        let popularity = JSON["popularity"] as? Double
        guard let department = JSON["department"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -department-")
        }
        let profilePath = JSON["profile_path"] as? String ?? ""
        guard let creditID = JSON["credit_id"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -credit_id-")
        }
        self.name = name
        self.job = job
        self.id = id
        self.knowForDepartment = knowForDepartment
        self.popularity = popularity
        self.department = department
        self.profilePath = profilePath
        if self.profilePath != "" {
            self.profileURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.profilePath!)!
        }
        self.creditID = creditID
    }
    
    var name: String
    var job: String
    var id: Int
    var hashValue : Int { return self.id }
    var knowForDepartment: String?
    var popularity: Double?
    var profilePath: String?
    var department: String?
    var profileURL: URL?
    var creditID: String?
    var biography: String = ""
    
    
    init(name: String, job: String, id: Int) {
        self.name = name
        self.job = job
        self.id = id
    }
    
    lazy var shortBiography: String = {
        var shortBiography = ""
        
        // Get first 2 sentences
        var addedSentences = 0
        biography.enumerateSubstrings(in: biography.startIndex..<biography.endIndex, options: .bySentences) { (substring, substringRange, enclosingRange, stop) in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                shortBiography = sentence
                addedSentences += 1
                if addedSentences == 2 {
                    stop = true
                }
            }
        }
        return shortBiography
    }()
    
    static func ==(lhs: Crew, rhs: Crew) -> Bool {
        return lhs.id == rhs.id
    }
}

class Actor: JSONDecodable, Equatable, Hashable, Comparable {
    static func < (lhs: Actor, rhs: Actor) -> Bool {
        lhs.id > rhs.id
    }
    var name: String
    var id: Int
    var hashValue : Int { return self.id }
    var knowForDepartment: String?
    var popularity: Double?
    var profilePath: String?
    var profileURL: URL?
    var creditID: String?
    var character: String?
    var order: Int?
    var castID: Int?
    var fullyDetailed: Bool = false
    var biography: String = ""
    var relatedMovies: [MovieWithGenres] = []
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    required init?(JSON: [String: AnyObject]) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        guard let knowForDepartment = JSON["known_for_department"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -knowForDepartment-")
        }
        guard let popularity = JSON["popularity"] as? Double else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -popularity-")
        }
        let profilePath = JSON["profile_path"] as? String ?? ""
        guard let creditID = JSON["credit_id"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -credit_id-")
        }
        guard let character = JSON["character"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -character-")
        }
        guard let castID = JSON["cast_id"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -cast_id-")
        }
        guard let order = JSON["order"] as? Int else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -order-")
        }
        self.name = name
        self.id = id
        self.knowForDepartment = knowForDepartment
        self.popularity = popularity
        self.character = character
        self.profilePath = profilePath
        if self.profilePath != "" {
            self.profileURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.profilePath!)!
        }
        self.creditID = creditID
        self.order = order
        self.castID = castID
    }
    
    lazy var shortBiography: String = {
        var shortBiography = ""
        
        // Get first 2 sentences
        var addedSentences = 0
        biography.enumerateSubstrings(in: biography.startIndex..<biography.endIndex, options: .bySentences) { (substring, substringRange, enclosingRange, stop) in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                shortBiography = sentence
                addedSentences += 1
                if addedSentences == 2 {
                    stop = true
                }
            }
        }
        return shortBiography
    }()
    
    static func ==(lhs: Actor, rhs: Actor) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PersonOfMovie {
    var movieId: Int
    var actor: Actor
    
    init?(JSON: [String: AnyObject], movieId: Int) throws {
        guard let name = JSON["name"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
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

struct Movie: JSONDecodable, Hashable, Equatable {
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
    var imdbID: String?
    var doubanID: String?
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
    var fullyDetailed: Bool = false
    var actors: [Actor] = []
    var directors: [Crew] = []
    var crews: [Crew] = []
    var clips: [YouTubeItem] = []
    var posterImage: UIImage?
    var bgImage: UIImage?
    
    init(title: String, id: Int, genreIds: [Genre]?) {
        self.title = title
        self.id = id
        self.genres = genreIds
    }
    
    required init?(JSON: [String: AnyObject]) throws {
        guard let title = JSON["title"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -name-")
        }
        guard let id = JSON["id"] as? Int else {
           throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -id-")
        }
        let imdbID = JSON["imdb_id"] as? String
        let genres = JSON["genres"] as? [[String:AnyObject]] ?? []
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
        let poster_path = JSON["poster_path"] as? String ?? nil
        guard let langue = JSON["original_language"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -original_language-")
        }
        guard let overview = JSON["overview"] as? String else {
            throw ErrorApi.jsonInvalidKeyOrElement("error - key or element invalid -overview-")
        }
        let bg_path = JSON["backdrop_path"] as? String ?? ""
        let revenue = JSON["revenue"] as? Int ?? 0
        self.title = title
        self.id = id
        self.imdbID = imdbID
        self.genres = genres.flatMap {
            do {
                return try Genre(JSON: $0)
            } catch (let error) {
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
        if self.poster_path != nil {
            self.posterURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.poster_path!)!
        }
        if self.bg_path != nil {
            self.bgURL = URL(string: "https://image.tmdb.org/t/p/original/" + self.bg_path!)!
        }
        self.original_language = langue
        self.overview = overview
        self.revenue = revenue
        var section_count = 0
        if
            let movieVideos = JSON["videos"] as? [String: AnyObject],
            let movieVideoResults = movieVideos["results"] as? [[String: AnyObject]] {
            
            var clips: [YouTubeItem] = []
            for video in movieVideoResults {
                guard
                    let site = video["site"] as? String,
                    site == "YouTube",
                    let title = video["name"] as? String, !title.isEmpty,
                    let tmdbId = video["id"] as? String, !tmdbId.isEmpty,
                    let ytKey = video["key"] as? String, !ytKey.isEmpty,
                    let type = video["type"] as? String, !type.isEmpty
                    else {
                        continue
                }
                
                let ytItem = YouTubeItem()
                ytItem.title = title
                ytItem.tmdbId = tmdbId
                ytItem.youtubeId = ytKey
                ytItem.type = type
                
                clips.append(ytItem)
            }
            self.clips = clips
            section_count += 1
        }
        
        if
            let movieCredits = JSON["credits"] as? [String: AnyObject],
            let movieCast = movieCredits["cast"] as? [[String: AnyObject]] {
            
            var actors: [Actor] = []
            for castMember in movieCast {
                guard
                    let actor = try Actor(JSON: castMember)
                    else {
                        continue
                }

                actors.append(actor)
                // Fetch a max of 10 actors
                if actors.count > 10 {
                    break
                }
            }
            self.actors =  Array(Set(actors))
            section_count += 1
        }
        
        if
            let movieCredits = JSON["credits"] as? [String: AnyObject],
            let movieCrew = movieCredits["crew"] as? [[String: AnyObject]] {
            var crews: [Crew] = []
            var directors: [Crew] = []
            for castMember in movieCrew {
                guard
                    let crew = try Crew(JSON: castMember)
                    else {
                        continue
                }
                if crew.department == "Directing" {
                        directors.append(crew)
                } else {
                    crews.append(crew)
                }
            }
            self.directors = directors
            self.crews = Array( Array(Set(crews)).prefix(10))
            section_count += 1
        }
        if section_count == 3 {
            self.fullyDetailed = true
        }
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

