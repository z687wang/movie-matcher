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
var activeMovies: [MovieWithGenres] = []
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

class DisplayMovieMainViewController: UIViewController, SwipeableCardViewDataSource {

    @IBOutlet weak var MovieNameLabel: UILabel!
    @IBOutlet weak var MovieYearLabel: UILabel!
    @IBOutlet weak var MoviesView: UIView!
    @IBOutlet weak var swipeableCardView: SwipeableCardViewContainer!
    
    var apiClient = MovieApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        loadMoviesIDData();
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 90.0)
        swipeableCardView.dataSource = self
        swipeableCardView.controller = self
    }
    
    func loadMoviesIDData() {
        print("start to load data")
        fetchInitialMoviesID(with: page)
    }
    
    func numberOfCards() -> Int {
        return activeMovies.count
    }
    
    func card(forItemAtIndex index: Int) -> SwipeableCardViewCard {
        let movieModel = activeMovies[index]
        let cardView = SampleSwipeableCard()
        cardView.viewModel = movieModel
        return cardView
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
        print(page)
        self.apiClient.fetchMoviesID(page: page) { [weak self] (results) in
            switch results {
            case .failure(let error):
                print(error)
            case .success(let resource, let hasPage):
                movieIDArray = resource
                hasNextPage = hasPage
                print(movieIDArray)
                self?.fetchGroupMoviesDetails(from: movieIDArray, completionHandler: { movies in
                    print(movies)
                })
            }
    
        }
    }
    
    func fetchMovieDetails(from id: Int, completionHandler: @escaping (_ movie: Movie)-> Void) {
        let group = DispatchGroup()
        group.enter()
        self.apiClient.fetchMovieDetails(movieId: String(id), completion:{ (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let resource , _):
                activeMovies.append(resource)
            }
            group.leave()
        })
    }
    
    func fetchGroupMoviesDetails(from moviesId: [Int], completionHandler: @escaping (_ movies: [MovieWithGenres])-> Void) {
        let group = DispatchGroup()
        for id in moviesId {
            group.enter()
            activeMovies = []
            self.apiClient.fetchMovieDetails(movieId: String(id), completion:{ (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let resource , _):
                    activeMovies.append(resource)
                    self.swipeableCardView.reloadData()
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

