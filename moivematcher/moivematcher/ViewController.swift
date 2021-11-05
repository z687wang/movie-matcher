//
//  ViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-10-27.
//

import UIKit

class ViewController: UIViewController {
    
    var page = 3
    var apiClient = MovieNightApiClient()
    var movies = [Movie]()
    var selectedMovies = [Int: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
    }

    func loadData() {
        fetchMovies(with: page)
    }
    
    func fetchMovies(with page: Int) {
        
        var head = "title,release date,genre,vote average"
        
        apiClient.fetchMovies(page: page) { [weak self] (results) in
            switch results {
                case .failure(let error) :
                    print(error)
                case .success(let resource, let hasPage) :
                for movie in resource {
                    head += "\n" + movie.title + "," + movie.releaseDate!
                    head += "," + String(movie.genreIds![0])
                    head += "," + String(movie.voteAverage ?? -1)
                    self?.apiClient.fetchMoviesPosters(movieId: String(movie.id), completion: { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success((let resource , _)):
                            print(resource[0])
                        }
                    })
                }
                self?.saveCSV(fileData: head)
            }
        }
        
    }
    
    func saveCSV(fileData: String) {
        //First make sure you know your file path, you can get it from user input or whatever
        //Keep the path clean of the name for now
        var filePath = "/Users/yalucai/Documents/"
        //then you need to pick your file name
        let fileName = "AwesomeFile.csv"

        // Create a FileManager instance this will help you make a new folder if you don't have it already
        let fileManager = FileManager.default

        //Create your target directory
        do {
            try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
           //Now it's finally time to complete the path
            filePath += fileName
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }

        //Then simply write to the file
        do {
           // Write contents to file
            try fileData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            print("Writing CSV to: \(filePath)")
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}

