//
//  ACPaginationView.swift
//
//  Created by Alejandro D. Cotilla on 2/21/15.
//  Copyright (c) 2015 Alejandro D. Cotilla. All rights reserved.
//

import UIKit

protocol ACPaginationViewDelegate: class {
    func paginationView(_ paginationView: ACPaginationView, didSelect index: Int)
}

class ACPaginationView: UIView {
    
    weak var delegate: ACPaginationViewDelegate?
    
    private(set) var circlesCount: Int!
    private(set) var circlesDiameter: CGFloat!
    private(set) var circlesInnerSpacing: CGFloat!
    
    private(set) var insets: UIEdgeInsets!

    private(set) var elasticMarker: UIView!
    
    lazy var circles: [UIView] = {
        let circles = self.subviews.sorted { (v1, v2) -> Bool in
            let x1 = v1.frame.origin.x
            let x2 = v2.frame.origin.x
            return x1 < x2
            }.filter { (v) -> Bool in
                return v != elasticMarker
        }
        
        return circles
    }()
    
    var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else {
                return
            }
            
            // Get x position for the given index
            let nextX = insets.left + (circlesInnerSpacing + circlesDiameter) * CGFloat(selectedIndex)
            
            let diff = nextX - elasticMarker.frame.origin.x
            let elasticity = circlesInnerSpacing + circlesInnerSpacing * 0.15;
            
            // Animate index jump
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.elasticMarker.frame = CGRect(x: self.elasticMarker.frame.origin.x + diff / 2, y: self.insets.top, width: self.circlesDiameter + elasticity, height: self.circlesDiameter)
            }) { (finished) in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    self.elasticMarker.frame = CGRect(x: nextX, y: self.insets.top, width: self.circlesDiameter, height: self.circlesDiameter)
                }, completion: nil)
            }
        }
    }
    
    init(diameter: CGFloat, innerSpacing: CGFloat, count: Int, normalColor: UIColor, highlightedColor: UIColor, insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)) {
        super.init(frame: .zero)
        
        self.insets = insets
        
        circlesCount = count
        circlesDiameter = diameter
        circlesInnerSpacing = innerSpacing
        
        var x = insets.left
        let y = insets.top
        
        elasticMarker = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        elasticMarker.backgroundColor = highlightedColor
        elasticMarker.layer.cornerRadius = elasticMarker.frame.width / 2.0
        elasticMarker.dropShadow(color: .black, radius: 1.0, opacity: 0.8, offset: .zero, grazingCornerRadius: true)
        elasticMarker.frame.origin = CGPoint(x: x, y: y)
        addSubview(elasticMarker)
        
        for index in 0..<count {
            let circularView = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            circularView.tag = index
            circularView.backgroundColor = normalColor
            circularView.layer.cornerRadius = circularView.frame.width / 2.0
            circularView.frame.origin = CGPoint(x: x, y: y)
            insertSubview(circularView, belowSubview: elasticMarker)
            
            x += innerSpacing + circularView.frame.width
        }
        
        self.frame.size = CGSize(width: x - innerSpacing + insets.left + insets.right, height: diameter + insets.top + insets.bottom)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:)))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func viewTapped(gesture: UITapGestureRecognizer) {
        let tapPointX = gesture.location(in: self).x
        
        // Check which circle is closer to the tap point
        var circleIndex: Int = 0
        var minDistance: CGFloat = 9999
        for (index, circle) in circles.enumerated() {
            let distance = abs(circle.center.x - tapPointX)
            if distance < minDistance {
                minDistance = distance
                circleIndex = index
            }
        }
        
        if selectedIndex != circleIndex {
            selectedIndex = circleIndex
            delegate?.paginationView(self, didSelect: selectedIndex)
        }
    }
}
