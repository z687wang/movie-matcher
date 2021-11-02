//
//  MovieMatcherModel.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/1/21.
//

import Foundation

//Model

enum ErrorApi : Error {
    case jsonInvalidKeyOrElement(String)
}

protocol JSONDecodable {
    init?(JSON: [String: AnyObject]) throws
}

enum UserKeys: String {
    case FoxUserGenres
    case FoxUserActors
    case FoxUserMovies
    
    case CrabUserGenres
    case CrabUserActors
    case CrabUserMovies
}

enum User {
    case Fox
    case Crab
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

struct Credit {
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



