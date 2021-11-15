//
//  DisplayMovieMainViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-07.
//

import UIKit
import SwiftUI
import Combine
import CoreData

var movieIDArray: [Int] = []
var likedMovieIDArray: [Int] = []
var dislikedMovieIDArray: [Int] = []
var notInterestedMovieIDArary: [Int] = []
var saveForLaterMovieIDArray: [Int] = []
var genresLikedDict: [String: [Int]] = [:]
var directorsLikedDict: [String: [Int]] = [:]
var actorsLikedDict: [String: [Int]] = [:]
var page: Int = 1
var hasNextPage: Bool = true
var genresLikedArray: [String] = []
var actorsLikedArray: [Actor] = []

class MainViewController: UIViewController, SwipeableCardViewDataSource {
    @IBOutlet weak var swipeableCardView: SwipeableCardViewContainer!
    var recommendationViewModel = RecommendationViewModel()
    var apiClient = MovieApiClient()
    var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // deletePages()
        loadMoviesIDData();
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 90.0)
        swipeableCardView.dataSource = self
        swipeableCardView.controller = self
        self.insertGradientBackground()
        
        // uncommented if need reset entity
        // deleteLikedMovies()
        // deleteDislikedMovies()
        // deleteNotInterestedMovies()
        // deleteLaterMovies()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        likedMovieIDArray = getLikedMovieIds()
        dislikedMovieIDArray = getDislikedMovieIds()
        saveForLaterMovieIDArray = getLaterMoviesIds()
        notInterestedMovieIDArary = getNotInterestedMovieIds()
        
    }
    func insertGradientBackground() {
        self.gradientLayer = CAGradientLayer()
        let colorTop =  UIColor(red: 0.18, green: 0.75, blue: 0.78, alpha: 1.00).cgColor
        let colorBottom = UIColor(red: 0.19, green: 0.09, blue: 0.42, alpha: 1.00).cgColor
        self.gradientLayer!.colors = [colorTop, colorBottom]
        self.gradientLayer!.startPoint = CGPoint(x: 0, y: 0)
        self.gradientLayer!.endPoint = CGPoint(x: 0, y: 1)
        self.gradientLayer!.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer!, at:0)
    }
    
    func setGradientBackground(topColor: UIColor, botColor: UIColor) {
        let colorTop =  topColor.cgColor
        let colorBottom = botColor.cgColor
        self.gradientLayer!.colors = [colorTop, colorBottom]
    }
    
    func loadMoviesIDData() {
        print("start to load data")
        if(page % 2 == 0){
            showRecommendMoviesID(with: page)
        } else{
            fetchInitialMoviesID(with: page)
            
        }
        page += 1
        savePage(page: page)
        getLatestPage()
    }
    
    func numberOfCards() -> Int {
        return movieIDArray.count
    }
    
    func card(forItemAtIndex index: Int) -> SwipeableCardViewCard {
        let movieID = movieIDArray[index]
        let cardView = SampleSwipeableCard()
        self.fetchMovieDetails(from: movieID, completionHandler: { movie in
            cardView.viewModel = movie
        })
        return cardView
    }
    
    func endSwipeAction(onView view: SwipeableView) {
        let swipeDirection = view.swipeDirection!
        let targetMovie = view.model!
        let targetMovieID = targetMovie.id
        let targetMovieGenre = targetMovie.genres
        let targetMovieActors = targetMovie.actors
        let targetMovieDirectors = targetMovie.directors
        if(view.model != nil){
            let targetMovie = view.model!
            let targetMovieID = targetMovie.id
            switch swipeDirection {
            case .left:
                for g in targetMovieGenre! {
                    genresLikedArray.append(g.name)
                }
                for a in targetMovieActors {
                    actorsLikedArray.append(a)
                }
                if !likedMovieIDArray.contains(targetMovieID) {
                    likedMovieIDArray.append(targetMovieID)
                    saveLikedMovie(movie: targetMovie)
                    self.recommendationViewModel.rateCurrentMovie( id: targetMovie.id , rating: 5)
                }
            case .right:
                if !dislikedMovieIDArray.contains(targetMovieID) {
                    dislikedMovieIDArray.append(targetMovieID)
                    saveDislikedMovie(movie: targetMovie)
                    self.recommendationViewModel.rateCurrentMovie(id: targetMovie.id, rating: 1)
                }
            case .up, .topLeft, .topRight:
                if !saveForLaterMovieIDArray.contains(targetMovieID) {
                    saveForLaterMovieIDArray.append(targetMovieID)
                    saveLaterMovie(movie: targetMovie)
                    self.recommendationViewModel.rateCurrentMovie(id: targetMovie.id, rating: 4)
                }
            case .down, .bottomLeft, .bottomRight:
                if !notInterestedMovieIDArary.contains(targetMovieID) {
                    notInterestedMovieIDArary.append(targetMovieID)
                    self.recommendationViewModel.rateCurrentMovie(id: targetMovie.id, rating: 2)
                    saveNotInterestedMovie(movie: targetMovie)
                }
                
            }
        }
    }
    
    func didSelect(card: SwipeableCardViewCard, atIndex index: Int) {
        let activeMovie = card.model
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "MyMovieDetailViewController") as! MovieDetailViewController
        destVC.movieData = activeMovie
        self.present(destVC, animated: true, completion: nil)
    }
    
    func viewForEmptyCards() -> UIView? {
        return nil
    }
    
    func fetchInitialMoviesID(with page: Int) {
        print("current page:")
        print(page)
        print("Liked Movie ID")
        print(likedMovieIDArray)
        print("Disliked Movie ID")
        print(dislikedMovieIDArray)
        self.apiClient.fetchMoviesID(page: page) { [weak self] (results) in
            switch results {
            case .failure(let error):
                print(error)
            case .success(let resource, let hasPage):
                movieIDArray = resource
                hasNextPage = hasPage
                print("Next Patch of Movie IDs")
                print(movieIDArray)
                self?.swipeableCardView.reloadData()
            }
        }
    }
    
    func showRecommendMoviesID(with page: Int) {
        print("current page:")
        print(page)
        print("Liked Movie ID")
        print(likedMovieIDArray)
        print("Disliked Movie ID")
        print(dislikedMovieIDArray)
        movieIDArray = []
        for i in self.recommendationViewModel.recommendMovies(){
            movieIDArray.append(Int(i))
        }
        print("Next Patch of Movie IDs")
        print(movieIDArray)

        self.swipeableCardView.reloadData()
    }
    
    func fetchMovieDetails(from id: Int, completionHandler: @escaping (_ movie: MovieWithGenres)-> Void) {
        let group = DispatchGroup()
        group.enter()
        self.apiClient.fetchMovieDetails(movieId: String(id), completion:{ (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let resource , _):
                completionHandler(resource)
            }
            group.leave()
        })
    }
    
    func fetchGroupMoviesDetails(from moviesId: [Int], completionHandler: @escaping (_ movies: [MovieWithGenres])-> Void) {
        let group = DispatchGroup()
        for id in moviesId {
            group.enter()
            self.apiClient.fetchMovieDetails(movieId: String(id), completion:{ (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let resource , _):
                    print(resource)
//                    activeMovies.append(resource)
                }
                group.leave()
            })
        }
    }
}

// liked
func saveLikedMovie(movie: MovieWithGenres) {
    saveMovies(movie: movie, entityName: "LikedMovies")
}

func getLikedMovieIds() -> [Int] {
    return getMoviesIds(entityName: "LikedMovies")
}

func deleteLikedMovies() {
    deleteEntity(entityName: "LikedMovies")
}

// disliked
func saveDislikedMovie(movie: MovieWithGenres) {
    saveMovies(movie: movie, entityName: "DislikedMovies")
}

func getDislikedMovieIds() -> [Int] {
    return getMoviesIds(entityName: "DislikedMovies")
}

func deleteDislikedMovies() {
    deleteEntity(entityName: "DislikedMovies")
}

// not interested
func saveNotInterestedMovie(movie: MovieWithGenres) {
    saveMovies(movie: movie, entityName: "NotInterestedMovies")
}

func getNotInterestedMovieIds() -> [Int] {
    return getMoviesIds(entityName: "NotInterestedMovies")
}

func deleteNotInterestedMovies() {
    deleteEntity(entityName: "NotInterestedMovies")
}

// save for later
func saveLaterMovie(movie: MovieWithGenres) {
    saveMovies(movie: movie, entityName: "LaterMovies")
}

func getLaterMoviesIds() -> [Int] {
    return getMoviesIds(entityName: "LaterMovies")
}

func deleteLaterMovies() {
    deleteEntity(entityName: "LaterMovies")
}

func saveMovies(movie: MovieWithGenres, entityName: String) {
    // Get the context
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    // Create a new Entity object & set some data values
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    let newMovie = NSManagedObject(entity: entity!, insertInto: context)
    newMovie.setValue(movie.id, forKey: "id")
   
    // Save the data
    do {
       try context.save() // Data Saved to persistent storage
      } catch {
       print("Error - CoreData failed saving")
    }
}

func getMoviesIds(entityName: String) -> [Int] {
    var ans : [Int] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    request.returnsObjectsAsFaults = false
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            print("\(entityName): \(data.value(forKey: "id") as! Int)")
            ans.append(data.value(forKey: "id") as! Int)
        }
    } catch {
        print("Error - CoreData failed reading")
    }
    return ans
}

func deleteEntity(entityName: String) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let request = NSBatchDeleteRequest(fetchRequest: fetch)
    request.resultType = .resultTypeObjectIDs
    do {
        let result = try context.execute(request) as? NSBatchDeleteResult
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey : objectIDArray]
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: changes,
            into: [context])
    } catch {
        fatalError("Failed to execute request: \(error)")
    }
}

func savePage(page: Int) {
    // Get the context
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    // Create a new Entity object & set some data values
    let entity = NSEntityDescription.entity(forEntityName: "Pages", in: context)
    let newPage = NSManagedObject(entity: entity!, insertInto: context)
    newPage.setValue(page, forKey: "pageNum")
   
    // Save the data
    do {
       try context.save() // Data Saved to persistent storage
      } catch {
       print("Error - CoreData failed saving")
    }
}

func getLatestPage() -> Int {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pages")
    request.returnsObjectsAsFaults = false
    var myPages : [Int] = []
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            print("page number: \(data.value(forKey: "pageNum") as! Int)")
            myPages.append(data.value(forKey: "pageNum") as! Int)
        }
    } catch {
        print("Error - CoreData failed reading")
    }
    let ans = myPages.max() ?? 0
    print("next page: \(ans)")
    return ans
}

func deletePages() {
    deleteEntity(entityName: "Pages")
}
