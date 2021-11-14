import UIKit
import Nuke

final class MoviesTableCell: UICollectionViewCell {
    

    @IBOutlet private weak var backdropImageView: ShadowImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private(set) weak var posterImageView: ShadowImageView!
    var apiClient = MovieApiClient()
    var viewModel: MovieWithGenres? {
        didSet {
            setupBindables()
        }
    }

    private func setupUI() {
        isAccessibilityElement = true
        titleLabel.font = UIFont(name: "Nunito-Bold", size: 22)!
        releaseDateLabel.font = UIFont(name: "Nunito-Black", size: 17)!
    }
    
    func populate(movieID: Int) {
        self.setupUI()
        self.fetchMovieDetails(from: movieID, completionHandler: { movie in
            self.viewModel = movie
        })
    }

    // MARK: - Reactive Behavior

    private func setupBindables() {
        guard let viewModel = viewModel else { return }

        titleLabel.text = viewModel.title
        accessibilityLabel = viewModel.title

        releaseDateLabel.text = viewModel.releaseDate
        if let imageUrl = viewModel.posterURL {
            ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                switch result {
                case let .success(response):
                    guard let strongSelf = self else { return }
                    let image = response.image
                    strongSelf.posterImageView.image = image
                case .failure(_):
                    break
                }
            }
        }
        
        if let imageUrl = viewModel.bgURL {
            ImagePipeline.shared.loadImage(with: imageUrl, progress: nil) { [weak self] (result) in
                switch result {
                case let .success(response):
                    guard let strongSelf = self else { return }
                    let image = response.image
                    strongSelf.backdropImageView.image = image
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
