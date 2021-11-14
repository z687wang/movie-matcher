//
//  MovieCollectionCell.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-12.
//

import Foundation

import UIKit
import Nuke

final class MoviesCollectionCell: UICollectionViewCell {
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: ShadowImageView!
    var apiClient = MovieApiClient()
    var viewModel: MovieWithGenres? {
        didSet {
            setupBindables()
        }
    }
    // MARK: - Private

    private func setupUI() {
//        titleLabel.textColor = UIColor.white
//        titleLabel.numberOfLines = 0
//        titleLabel.font = UIFont(name: "Nunito-Black", size: 18)!
    }

    func populate(movieID: Int) {
        self.setupUI()
        self.fetchMovieDetails(from: movieID, completionHandler: { movie in
            self.viewModel = movie
        })
    }

    private func setupBindables() {
        guard let viewModel = viewModel else { return }
//        titleLabel.text = viewModel.title
        if let imageUrl = viewModel.posterURL {
            ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                switch result {
                case let .success(response):
                    guard let strongSelf = self else { return }
                    let image = response.image
                    self!.posterImageView.image = image
                case .failure(_):
                    break
                }
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

}
