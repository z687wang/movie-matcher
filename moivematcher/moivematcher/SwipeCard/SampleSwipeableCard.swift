//
//  SampleSwipeableCard.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import Foundation

import UIKit
import CoreMotion

class SampleSwipeableCard: SwipeableCardViewCard {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var imageView: ShadowImageView!
    @IBOutlet private weak var backgroundContainerView: UIView!
    @IBOutlet private weak var imageBackgroundColorView: UIView!
    /// Core Motion Manager
    private let motionManager = CMMotionManager()
    /// Shadow View
    private weak var shadowView: UIView?

    /// Inner Margin
    private static let kInnerMargin: CGFloat = 20.0

    public var viewModel: MovieWithGenres? {
        didSet {
            configure(forViewModel: viewModel)
        }
    }

    private func configure(forViewModel viewModel: MovieWithGenres?) {
        if let viewModel = viewModel {
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.releaseDate
            genresLabel.text = viewModel.genresStr
            // uncommented for dynamic fit
            /*
            titleLabel.numberOfLines = 0
            titleLabel.adjustsFontSizeToFitWidth = true
            genresLabel.numberOfLines = 0
            genresLabel.adjustsFontSizeToFitWidth = true
             */
//           imageBackgroundColorView.backgroundColor = viewModel.color
            let url = URL(string: "https://image.tmdb.org/t/p/original/" + viewModel.poster_path!)!
            self.downloadImage(from: url)
            backgroundContainerView.layer.cornerRadius = 14.0
            self.model = viewModel
        }
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                let image = UIImage(data: data)!
                let targetSize = CGSize(width: 360, height: 540)
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
                self?.imageView.image = scaledImage
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        configureShadow()
    }

    // MARK: - Shadow

    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: SampleSwipeableCard.kInnerMargin,
                                              y: SampleSwipeableCard.kInnerMargin,
                                              width: bounds.width - (2 * SampleSwipeableCard.kInnerMargin),
                                              height: bounds.height - (2 * SampleSwipeableCard.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView

        // Roll/Pitch Dynamic Shadow
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.02
//            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
//                if let motion = motion {
//                    let pitch = motion.attitude.pitch * 10 // x-axis
//                    let roll = motion.attitude.roll * 10 // y-axis
//                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
//                }
//            })
//        }
        self.applyShadow(width: CGFloat(0.0), height: CGFloat(0.0))
    }

    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.15
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }

}
