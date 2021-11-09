//
//  MovieMetaDataCell.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-09.
//

import Foundation
import UIKit

class MovieMetadataCellView: UICollectionViewCell, NameDescribable {

    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearHolderLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var revenueHolderLabel: UILabel!
    @IBOutlet weak var popularityHolderLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
}
