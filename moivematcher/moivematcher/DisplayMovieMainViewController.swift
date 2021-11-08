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
var page: Int = 1
var hasNextPage: Bool = true

class ActiveMoviesModel: ObservableObject {
    var didChange = PassthroughSubject<Void, Never>()
    var activeMovies: [MovieWithGenres] { didSet { didChange.send() } }
    init(activeMovies: [MovieWithGenres]) {
            self.activeMovies = activeMovies
        }
}

var activeMoviesModel = ActiveMoviesModel(activeMovies: [])

struct MoviesSectionView: View {
    @ObservedObject var moviesModel: ActiveMoviesModel
    var body: some View {
        ZStack{
            ForEach(moviesModel.activeMovies) { movie in
                MoviePosterView(movie: movie)
            }
        }
        .padding(8)
        .zIndex(1.0)
    }
}

class MoviesSectionSwiftUIViewHostingController: UIHostingController<MoviesSectionView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: MoviesSectionView(moviesModel: activeMoviesModel))
    }
    func setNeedsBodyUpdate() {
        
    }
}

struct MoviePosterView: View {
    @State var movie: MovieWithGenres
    let movieGradient = Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)])
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: movie.poster_path!));
                
            // Linear Gradient
            LinearGradient(gradient: movieGradient, startPoint: .top, endPoint: .bottom)
            VStack {
                Spacer()
                VStack(alignment: .leading){
                    HStack {
                        Text(movie.title).font(.largeTitle).fontWeight(.bold)
                        Text(String(movie.releaseDate!)).font(.title)
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
        }
        
        .cornerRadius(8)
        .offset(x: movie.x, y: movie.y)
        .rotationEffect(.init(degrees: movie.degree))
        .gesture (
            DragGesture()
                .onChanged { value in
                    withAnimation(.default) {
                        movie.x = value.translation.width
                        // MARK: - BUG 5
                        movie.y = value.translation.height
                        movie.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                    }
                }
                .onEnded { (value) in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            movie.x = 0; movie.degree = 0; movie.y = 0
                        case let x where x > 100:
                            movie.x = 500; movie.degree = 12
                        case (-100)...(-1):
                            movie.x = 0; movie.degree = 0; movie.y = 0
                        case let x where x < -100:
                            movie.x  = -500; movie.degree = -12
                        default:
                            movie.x = 0; movie.y = 0
                        }
                    }
                }
        )
    }
}


class DisplayMovieMainViewController: UIViewController {

    @IBOutlet weak var MovieNameLabel: UILabel!
    @IBOutlet weak var MovieYearLabel: UILabel!
    @IBOutlet weak var MoviesView: UIView!
    
    var apiClient = MovieApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        loadMoviesIDData();
    }
    
    func loadMoviesIDData() {
        print("start to load data")
        fetchInitialMoviesID(with: page)
    }
    
    func fetchInitialMoviesID(with page: Int) {
        self.apiClient.fetchMoviesID(page: page) { [weak self] (results) in
            switch results {
            case .failure(let error):
                print(error)
            case .success(let resource, let hasPage):
                movieIDArray = resource
                hasNextPage = hasPage
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
                activeMoviesModel.activeMovies.append(resource)
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
                    activeMoviesModel.activeMovies.append(resource)
                }
                group.leave()
            })
        }
        
//        group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
//            completionHandler(movies)
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
