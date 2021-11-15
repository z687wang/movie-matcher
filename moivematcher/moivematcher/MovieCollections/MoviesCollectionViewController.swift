//
//  MovieCollectionViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-12.
//
import Foundation
import UIKit
import Nuke
import CollectionViewSlantedLayout


class MoviesCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: CollectionViewSlantedLayout!
    var mylikedMoviesIDArray: [Int] = []
    var likedMovies: [MovieWithGenres] = []
    var likeMoviesPosters: [UIImage] = []
    var gradientLayer: CAGradientLayer?
    var apiClient = MovieApiClient()
    let reuseIdentifier = "likedMoviesViewCell"

    override func loadView() {
        super.loadView()
    }
    
    private(set) var isContentReady: Bool = false {
        didSet {
            if isContentReady {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewLayout.isFirstCellExcluded = true
        collectionViewLayout.isLastCellExcluded = true
        collectionViewLayout.scrollDirection = .horizontal
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mylikedMoviesIDArray = getLikedMovieIds()
        self.fetchGroupMoviesDetails(from: self.mylikedMoviesIDArray) { movies in }
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func fetchGroupMoviesDetails(from moviesId: [Int], completionHandler: @escaping (_ movies: [MovieWithGenres])-> Void) {
        let group = DispatchGroup()
        self.likedMovies = []
        for id in moviesId {
            group.enter()
            self.apiClient.fetchMovieDetails(movieId: String(id), completion:{ (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let resource , _):
                    self.likedMovies.append(resource)
                    if let imageUrl = resource.posterURL {
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
                                self!.likeMoviesPosters.append(scaledImage)
                                if self!.likeMoviesPosters.count == self!.mylikedMoviesIDArray.count {
                                        self!.isContentReady = true
                                }
                            case .failure(_):
                                break
                            }
                        }
                    }
                }
                group.leave()
            })
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let settingsController = segue.destination as? SettingsController,
            let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout else {
            return
        }
        settingsController.collectionViewLayout = layout
    }
}

extension MoviesCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard isContentReady else {
            return 0
        }
        return self.mylikedMoviesIDArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                            as? MoviesCollectionSlantedCell else {
            fatalError()
        }
        cell.viewModel = likedMovies[indexPath.row]
        cell.imageView.image = likeMoviesPosters[indexPath.row]
        if let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout {
            cell.contentView.transform = CGAffineTransform(rotationAngle: layout.slantingAngle)
        }

        return cell
    }
}

extension MoviesCollectionViewController: CollectionViewDelegateSlantedLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("Did select item at indexPath: [\(indexPath.section)][\(indexPath.row)]")
        let cell = collectionView.cellForItem(at: indexPath) as? MoviesCollectionSlantedCell
        let activeMovie = cell!.viewModel
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "MyMovieDetailViewController") as! MovieDetailViewController
        destVC.movieData = activeMovie
        self.present(destVC, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: CollectionViewSlantedLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGFloat {
        return collectionViewLayout.scrollDirection == .vertical ? 275 : 325
    }
}

extension MoviesCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else {return}
        guard let visibleCells = collectionView.visibleCells as? [MoviesCollectionSlantedCell] else {return}
        for parallaxCell in visibleCells {
            let yOffset = (collectionView.contentOffset.y - parallaxCell.frame.origin.y) / parallaxCell.imageHeight
            let xOffset = (collectionView.contentOffset.x - parallaxCell.frame.origin.x) / parallaxCell.imageWidth
            parallaxCell.offset(CGPoint(x: xOffset * xOffsetSpeed, y: yOffset * yOffsetSpeed))
        }
    }
}



class SettingsController: UITableViewController {

    weak var collectionViewLayout: CollectionViewSlantedLayout!

    @IBOutlet weak var slantingDirectionSegment: UISegmentedControl!
    @IBOutlet weak var scrollDirectionSegment: UISegmentedControl!
    @IBOutlet weak var zIndexOrderSegment: UISegmentedControl!
    @IBOutlet weak var firstCellSlantingSwitch: UISwitch!
    @IBOutlet weak var lastCellSlantingSwitch: UISwitch!
    @IBOutlet weak var slantingSizeSlider: UISlider!
    @IBOutlet weak var lineSpacingSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        slantingDirectionSegment.selectedSegmentIndex = (collectionViewLayout.slantingDirection == .downward) ? 0 : 1
        scrollDirectionSegment.selectedSegmentIndex = (collectionViewLayout.scrollDirection == .horizontal) ? 0 : 1
        zIndexOrderSegment.selectedSegmentIndex = (collectionViewLayout.zIndexOrder == .descending) ? 0 : 1
        firstCellSlantingSwitch.isOn = collectionViewLayout.isFirstCellExcluded
        lastCellSlantingSwitch.isOn = collectionViewLayout.isLastCellExcluded
        slantingSizeSlider.value = Float(collectionViewLayout.slantingSize)
        lineSpacingSlider.value = Float(collectionViewLayout.lineSpacing)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    @IBAction func slantingDirectionChanged(_ sender: UISegmentedControl) {
        collectionViewLayout.slantingDirection = (sender.selectedSegmentIndex == 0 ? .downward : .upward )
    }

    @IBAction func scrollDirectionChanged(_ sender: UISegmentedControl) {
        collectionViewLayout.scrollDirection = (sender.selectedSegmentIndex == 0 ? .horizontal : .vertical)
    }

    @IBAction func zIndexOrderChanged(_ sender: UISegmentedControl) {
        collectionViewLayout.zIndexOrder = (sender.selectedSegmentIndex == 0 ? .descending : .ascending)
    }

    @IBAction func firstCellSlantingSwitchChanged(_ sender: UISwitch) {
        collectionViewLayout.isFirstCellExcluded = sender.isOn
    }

    @IBAction func lastCellSlantingSwitchChanged(_ sender: UISwitch) {
        collectionViewLayout.isLastCellExcluded = sender.isOn
    }

    @IBAction func slantingSizeChanged(_ sender: UISlider) {
        collectionViewLayout.slantingSize = UInt(sender.value)
    }

    @IBAction func lineSpacingChanged(_ sender: UISlider) {
        collectionViewLayout.lineSpacing = CGFloat(sender.value)
    }
    @IBAction func done(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: { [weak self] () -> Void in
            let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
            self?.collectionViewLayout.collectionView?.scrollRectToVisible(rect, animated: true)
        })
    }
}
