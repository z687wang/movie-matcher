//
//  MovieDetailViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import UIKit

class MediaHeaderView: UICollectionReusableView, NameDescribable {
    
    @IBOutlet weak var label: UILabel!
    
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



class DirectorCellView: UICollectionViewCell, NameDescribable {
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

class CrewCellView: UICollectionViewCell, NameDescribable {
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

class ActorCellView: UICollectionViewCell, NameDescribable {
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
