//
//  UIImage+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 2/19/19.
//  Copyright © 2019 Carolco LLC. All rights reserved.
//

import UIKit

extension UIImage {
    
    // Based on: https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let color = UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
        
        return color
    }
    
    /// Resize the image to a centain percentage
    ///
    /// - Parameter percentage: Percentage value
    /// - Returns: UIImage(Optional)
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = size.scaled(by: percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Method to create a UIImage from CALayer
    ///
    /// - Parameter layer: input Layer
    convenience init(layer: CALayer) {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
    }
    
    /// Apply Gaussian Blur to an image.
    ///
    /// - Parameter radius: the radius of the blur effect.
    /// - Returns: output UIImage
    func blurred(radius: Float) -> UIImage? {
        if let filter = CIFilter(name: "CIGaussianBlur"), let ciImage = CIImage(image: self) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(radius, forKeyPath: kCIInputRadiusKey)
            
            let context = CIContext(options: nil)
            if let output = filter.outputImage, let cgimage = context.createCGImage(output, from: ciImage.extent) {
                return UIImage(cgImage: cgimage, scale: UIScreen.main.scale, orientation: .up)
            }
        }
        
        return nil
    }
    
    // Source: https://stackoverflow.com/a/40815771/1792699
    func masked(with bezierPath: UIBezierPath) -> UIImage {
        // Define graphic context (canvas) to paint on
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        // Set the clipping mask
        bezierPath.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    func rounded() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        let diameter = min(imageWidth, imageHeight)
    
        let imageSize = CGSize(width: diameter, height: diameter)
        
        let ovalPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: imageSize))
        ovalPath.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    enum ScalingHorizontalAligment {
        case center
        case left
        case right
    }
    
    enum ScalingVerticalAligment {
        case center
        case top
        case bottom
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill, horizontalAligment: ScalingHorizontalAligment = .center, verticalAligment: ScalingVerticalAligment = .center) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        
        switch horizontalAligment {
        case .center:
            scaledImageRect.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
        case .left:
            scaledImageRect.origin.x = 0
        case .right:
            scaledImageRect.origin.x = newSize.width - size.width * aspectRatio
        }
        
        switch verticalAligment {
        case .center:
            scaledImageRect.origin.y = (newSize.height - size.height * aspectRatio) / 2.0
        case .top:
            scaledImageRect.origin.y = 0
        case .bottom:
            scaledImageRect.origin.y = newSize.height - size.height * aspectRatio
        }
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)

        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
