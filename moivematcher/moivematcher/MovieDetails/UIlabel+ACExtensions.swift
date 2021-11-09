//
//  UIlabel+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 6/23/18.
//  Copyright © 2018 Carolco LLC. All rights reserved.
//

import UIKit

extension UILabel {

    // TODO: Make generic and move to UIView+ACExtensions
    func clone() -> UILabel? {
        guard
            let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false),
            let label = ((try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UILabel) as UILabel??)
            else {
            return nil
        }
        
        return label
    }
    
    func numberOfVisibleLines() -> Int {
        guard let selfClone = self.clone() else {
            return 0
        }
        
        selfClone.translatesAutoresizingMaskIntoConstraints = true
        selfClone.sizeToFit()
        let maxSize = CGSize(width: selfClone.frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font!], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    
}
