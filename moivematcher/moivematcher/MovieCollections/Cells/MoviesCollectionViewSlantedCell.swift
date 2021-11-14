//
//  MoviesCollectionViewSlantedCell.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-13.
//

import Foundation

import CollectionViewSlantedLayout
import Nuke

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class MoviesCollectionSlantedCell: CollectionViewSlantedCell {

    @IBOutlet weak var imageView: UIImageView!
    private var gradient = CAGradientLayer()
    
    var apiClient = MovieApiClient()
    @IBOutlet weak var titleLabel: UILabel!
    var viewModel: MovieWithGenres? {
        didSet {
            setupBindables()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if let backgroundView = backgroundView {
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.0, 1.0]
            gradient.frame = backgroundView.bounds
            backgroundView.layer.addSublayer(gradient)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundView = backgroundView {
            gradient.frame = backgroundView.bounds
        }
    }

    var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }

    var imageHeight: CGFloat {
        return (imageView?.image?.size.height) ?? 0.0
    }

    var imageWidth: CGFloat {
        return (imageView?.image?.size.width) ?? 0.0
    }

    func offset(_ offset: CGPoint) {
        imageView.frame = imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    func populate(movieID: Int) {
//        self.setupUI()
        self.fetchMovieDetails(from: movieID, completionHandler: { movie in
            self.viewModel = movie
        })
    }
    
    private func setupBindables() {
        guard let viewModel = viewModel else { return }
//        self.titleLabel.text = viewModel.title
        if let imageUrl = viewModel.posterURL {
            ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                switch result {
                case let .success(response):
                    guard let strongSelf = self else { return }
                    let image = response.image
                    let targetSize = CGSize(width: 375, height: 563)
                    // Compute the scaling ratio for the width and height separately
                    let widthScaleRatio = targetSize.width / image.size.width
                    let heightScaleRatio = targetSize.height / image.size.height

                    // To keep the aspect ratio, scale by the smaller scaling ratio
                    let scaleFactor = min(widthScaleRatio, heightScaleRatio)
                    let scaledImageSize = CGSize(
                        width: image.size.width * scaleFactor,
                        height: image.size.height * scaleFactor
                    )
                    let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                    let scaledImage = renderer.image { _ in
                        image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                    }
                    self!.image = scaledImage
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
