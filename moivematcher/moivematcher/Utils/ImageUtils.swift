//
//  ImageUtils.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-15.
//

import Foundation
import UIKit




func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let targetSize = CGSize(width: 375, height: 563)
    let widthScaleRatio = targetSize.width / image.size.width
    let heightScaleRatio = targetSize.height / image.size.height
    let scaleFactor = min(widthScaleRatio, heightScaleRatio)
    let scaledImageSize = CGSize(
        width: image.size.width * scaleFactor,
        height: image.size.height * scaleFactor
    )
    let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
    let scaledImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
    }
    return scaledImage
}

