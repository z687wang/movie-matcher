//
//  DisplayMovieMainViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-07.
//

import UIKit
import SwiftUI
import Combine


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
var genresLikedArray: [String] = ["Action", "Adventure", "Animation"]
var actorsLikedArray: [String] = []

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
            for g in targetMovieGenre! {
                genresLikedArray.append(g.name)
            }
            print(genresLikedArray)
//            destVC.reloadData()
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

}

