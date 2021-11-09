//
//  MovieDetails.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import Foundation

import UIKit
import Nuke

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }
    
    static var typeName: String {
        return String(describing: self)
    }
}

protocol TypeErasedMediaCellView {
    var typeErasedImageView: ImageDisplayingView! { get }
}

protocol MediaCellView: TypeErasedMediaCellView {
    associatedtype MediaCellViewImage: ImageDisplayingView
    var imageView: MediaCellViewImage! { get }
}

extension MediaCellView {
    var typeErasedImageView: ImageDisplayingView! { return imageView }
}




class MediaDescriptionCellView: UICollectionViewCell, NameDescribable {

    private static let overviewLabelFont = UIFont(name: "Nunito-Regular", size: 17)!
    private static let overviewLabelTop: CGFloat = 10.0
    private static let overviewLabelTrailing: CGFloat = 18.0
    private static let overviewLabelLeading: CGFloat = 18.0
    @IBOutlet weak var topSeperator: UIView!
    
    @IBOutlet weak var overviewLabel: UILabel! {
        didSet {
            overviewLabel.font = MediaDescriptionCellView.overviewLabelFont
        }
    }
    
    @IBOutlet weak var overviewLabelTopConstraint: NSLayoutConstraint! {
        didSet {
            overviewLabelTopConstraint.constant = MediaDescriptionCellView.overviewLabelTop
        }
    }
    
    @IBOutlet weak var overviewLabelTrailingConstraint: NSLayoutConstraint! {
        didSet {
            overviewLabelTrailingConstraint.constant = MediaDescriptionCellView.overviewLabelTrailing
        }
    }
    @IBOutlet weak var overviewLabelLeadingConstraint: NSLayoutConstraint! {
        didSet {
            overviewLabelLeadingConstraint.constant = MediaDescriptionCellView.overviewLabelLeading
        }
    }
    
    class func cellHeightForOverview(_ overview: String, width: CGFloat) -> CGFloat {
        let overviewWidth = width - overviewLabelLeading - overviewLabelTrailing
        return overview.height(withConstrainedWidth: overviewWidth, font: MediaDescriptionCellView.overviewLabelFont) + overviewLabelTop * 2.0
    }
    
}

class PosterCellView: UICollectionViewCell, NameDescribable, MediaCellView {

    @IBOutlet weak var imageView: ShadowImageView!

}

class CircularCellView: UICollectionViewCell, NameDescribable {

    static let imageHorizontalPadding: CGFloat = 20
    
    @IBOutlet weak var imageView: ShadowImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint! {
        didSet {
            imageViewLeadingConstraint.constant = CircularCellView.imageHorizontalPadding
        }
    }
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint! {
        didSet {
            imageViewTrailingConstraint.constant = 20
        }
    }
}

