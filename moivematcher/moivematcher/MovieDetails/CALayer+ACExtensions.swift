//
//  CALayer+ACExtensions.swift
//  Vista
//
//  Created by Alejandro Cotilla on 4/13/21.
//

import UIKit

extension CALayer {
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)
        render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}

