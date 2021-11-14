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

//struct MoviesSectionView: View {
//    @ObservedObject var moviesModel: ActiveMoviesModel
//    var body: some View {
//        ZStack{
//            ForEach(moviesModel.activeMovies) { movie in
//                MoviePosterView(movie: movie)
//            }
//        }
//        .padding(8)
//        .zIndex(1.0)
//    }
//}

//class MoviesSectionSwiftUIViewHostingController: UIHostingController<MoviesSectionView> {
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder, rootView: MoviesSectionView(moviesModel: activeMoviesModel))
//    }
//    func setNeedsBodyUpdate() {
//
//    }
//}

class MainViewController: UIViewController, SwipeableCardViewDataSource {

    @IBOutlet weak var MovieNameLabel: UILabel!
    @IBOutlet weak var MovieYearLabel: UILabel!
    @IBOutlet weak var MoviesView: UIView!
    @IBOutlet weak var swipeableCardView: SwipeableCardViewContainer!
    
    var apiClient = MovieApiClient()
    var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        loadMoviesIDData();
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 90.0)
        swipeableCardView.dataSource = self
        swipeableCardView.controller = self
        self.insertGradientBackground()
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
        fetchInitialMoviesID(with: page)
        page += 1
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
        
        switch swipeDirection {
        case .left:
            likedMovieIDArray.append(targetMovieID)
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "LikedMoviesCollectionViewController") as! MoviesCollectionViewController
        case .right:
            dislikedMovieIDArray.append(targetMovieID)
        case .up, .topLeft, .topRight:
            saveForLaterMovieIDArray.append(targetMovieID)
        case .down, .bottomLeft, .bottomRight:
            notInterestedMovieIDArary.append(targetMovieID)
        }
    }
    
    func didSelect(card: SwipeableCardViewCard, atIndex index: Int) {
        let activeMovie = card.model
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "MyMovieDetailViewController") as! MovieDetailViewController
        destVC.movieData = activeMovie
//        destVC.modalPresentationStyle = .overFullScreen
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
        
//        group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
//            completionHandler(movies)
//        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

