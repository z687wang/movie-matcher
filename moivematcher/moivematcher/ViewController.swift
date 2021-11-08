//
//  ViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-10-27.
//

import UIKit

class ViewController: UIViewController {
    
    var apiClient = MovieApiClient()
    var movies = [Movie]()
    var selectedMovies = [Int: Int]()
    var names: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
    }

    func loadData() {
//        fetchGenres()
//        fetchMovies()
//        fetchPosters()
//        fetchDirector(id: String(774063))
//        fetchActor(movieId: String(774563))
//        fetchVideo(id: String(297761))
    }
    
    
//    func fetchDirector(id: String) {
//        apiClient.fetchMovieDirector(movieId: id, completion: { [weak self] (results) in
//            switch results {
//            case .failure(let error):
//                print(error)
//            case .success(let director, _):
//                // the director is fetched here
//                print(director)
//            }
//        })
//    }
//
////    Fetch the five leading actors of the movie with id=[movieId]
//    func fetchActor(movieId: String) {
//        apiClient.fetchMovieActors(movieId: movieId, completion: { [weak self] (results) in
//            switch results {
//            case .failure(let error) :
//                print(error)
//            case .success(let actors, _) :
//                self?.names += ","
//                if actors.isEmpty {
//                    self?.names += "No Actor"
//                }
//                else {
//                    for acteur in actors {
//                        self?.names += acteur.actor.name + " "
//                    }
//                }
//            }
//        })
//    }
    
    
    
//    func fetchMovies() {
//
//        let head = "title,release date,genre,vote average,popularity,poster,original language,adult,actors"
//        let semaphore = DispatchSemaphore(value: 0)
//        let myGroup = DispatchGroup()
//        saveCSV(fileData: head)
//        var body = ""
//        var movieIds: [String] = []
//
//        for page in 1...100 {
//            apiClient.fetchMovies(page: page) { [weak self] (results) in
//                switch results {
//                    case .failure(let error) :
//                        print(error)
//                case .success(let resource, _) :
//                    for movie in resource {
//                        body += "\n" + movie.title.replacingOccurrences(of: ",", with: "") + "," + movie.releaseDate!
//                        body += "," + movie.genreIds!.map{String($0)}.joined(separator: " ")
//                        body += "," + String(movie.voteAverage ?? -1)
//                        body += "," + (movie.popularity!).description
//                        body += "," + movie.poster_path!
//                        body += "," + movie.original_language!
//                        body += "," + movie.adult!.description
//                        movieIds.append(String(movie.id))
//                    }
//                    self?.saveCSV(fileData: body)
//                    body = ""
//                }
//            }
//        }
//    }
    
//    func saveCSV(fileData: String) {
////        print("save to CSV" + fileData)
//        //First make sure you know your file path, you can get it from user input or whatever
//        //Keep the path clean of the name for now
//        var filePath = "/Users/yalucai/Documents/"
//        //then you need to pick your file name
//        let fileName = "AwesomeFile.csv"
//
//        // Create a FileManager instance this will help you make a new folder if you don't have it already
//        let fileManager = FileManager.default
//
//        //Create your target directory
//        do {
//            try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
//           //Now it's finally time to complete the path
//            filePath += fileName
//        }
//        catch let error as NSError {
//            print("Ooops! Something went wrong: \(error)")
//        }
//
//        //Then simply write to the file
//        do {
//            if let fileHandle = FileHandle(forWritingAtPath: filePath) {
//                fileHandle.seekToEndOfFile()
//                fileHandle.write(Data(fileData.utf8))
//                fileHandle.closeFile()
//            }
//            else {
//                print("Can't open fileHandle")
//            }
//           // Write contents to file
////            try fileData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
////            print("Writing CSV to: \(filePath)")
//        }
////        catch let error as NSError {
////            print("Ooops! Something went wrong: \(error)")
////        }
//    }
}

