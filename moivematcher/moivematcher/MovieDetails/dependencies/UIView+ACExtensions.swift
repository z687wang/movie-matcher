//
//  UIView+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 3/4/18.
//  Copyright © 2018 Carolco LLC. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Stretches the input view to the UIView frame using Auto-layout
    ///
    /// - Parameter view: The view to stretch.
    func stretch(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// - Note: Stack Overflow: [Load a UIView from nib in Swift](https://stackoverflow.com/a/36388769/2108547).
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func copyConstraints(fromView sourceView: UIView) {
        guard let sourceViewSuperview = sourceView.superview else {
            return
        }
        for constraint in sourceViewSuperview.constraints {
            if constraint.firstItem as? UIView == sourceView {
                sourceViewSuperview.addConstraint(NSLayoutConstraint(item: self, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            } else if constraint.secondItem as? UIView == sourceView {
                sourceViewSuperview.addConstraint(NSLayoutConstraint(item: constraint.firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: self, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            }
        }
    }
    
    func dropShadow(color: UIColor = UIColor.black, radius: CGFloat = 3.0, opacity: Float = 0.65, offset: CGSize = CGSize(width: 4, height: 4), grazingCornerRadius: Bool = false) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.masksToBounds = false
        
        if (grazingCornerRadius) {
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        }
        else {
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }
    }
    
    // Based on https://stackoverflow.com/a/41217863/1792699
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    
}
