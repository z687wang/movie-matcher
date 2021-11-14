//
//  MovieCollectionViewCellProtocol.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-12.
//

import Foundation
import UIKit

protocol MoviesCollectionCellProtocol {

    var posterImageView: ShadowImageView! { get }
    var viewModel: MovieWithGenres? { get set }
    
}
