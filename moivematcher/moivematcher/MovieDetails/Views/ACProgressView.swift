//
//  ACProgressView.swift
//
//  Created by Alejandro Cotilla on 3/11/18.
//  Copyright © 2018 Carolco LLC. All rights reserved.
//

import UIKit

class ACProgressView: UIView, CAAnimationDelegate {

    var indeterminate = false {
        didSet {
            if oldValue == indeterminate {
                return
            }
            
            self.isHidden = false
            
            if indeterminate {
                progressLayer.strokeStart = 0.1
                progressLayer.strokeEnd = 1.0
                
                let animation = CABasicAnimation(keyPath: "transform.rotation")
                animation.toValue = Double.pi
                animation.duration = 0.5
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.repeatCount = MAXFLOAT
                animation.isCumulative = true
                
                self.backgroundLayer.add(animation, forKey: nil)
            } else {
                progressLayer.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
                progressLayer.strokeStart = 0.0
                progressLayer.strokeEnd = 0.0
                
                self.backgroundLayer.removeAllAnimations()
            }
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            if self.indeterminate {
                self.indeterminate = false
                RunLoop.current.run(until: Date())
            }
            
            if (progress > 1.0) {
                progress = 1.0
                return
            }
            if (progress < 0.0) {
                progress = 0.0
                return
            }
            
            if (progress > 0.0) {
                self.isHidden = false
            }
            
            self.progressLayer.actions = nil
            self.progressLayer.strokeEnd = progress
            
            if (progress >= 1.0) {
                self.performFinishAnimation()
            }
        }
    }

    var lineWidth: CGFloat = 0.0 {
        didSet {
            progressLayer.lineWidth = lineWidth
        }
    }
    
    var radius: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            progressLayer.strokeColor = tintColor.cgColor
        }
    }
    
    var animationDidStopBlock: (() -> Void)?
    
    var backgroundView: UIView! {
        didSet {
            if backgroundView.superview != nil {
                backgroundView.removeFromSuperview()
            }
            
            backgroundView.frame = self.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundLayer.removeFromSuperlayer()
            backgroundView.layer.addSublayer(backgroundLayer)
            
            self.addSubview(backgroundView)
        }
    }

    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.strokeColor = self.tintColor.cgColor
        progressLayer.lineWidth = self.lineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        return progressLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        
        self.lineWidth = 5.0
        self.radius = 38.0
        self.backgroundLayer.addSublayer(self.progressLayer)
        
        self.backgroundView = defaultBackgroundView()
        
        self.indeterminate = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundLayer.frame = self.bounds

        let path = UIBezierPath()
        path.lineCapStyle = CGLineCap.butt
        path.lineWidth = self.lineWidth
        path.addArc(withCenter: self.backgroundView.center, radius: self.radius + self.lineWidth / 2, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(Double.pi + Double.pi / 2), clockwise: true)

        self.progressLayer.path = path.cgPath
    }
    
    func defaultBackgroundView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        return backgroundView
    }
    
    func performFinishAnimation() {
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor

        let center = self.backgroundView.center
        
        let initialPath = UIBezierPath(rect: self.backgroundView.bounds)
        initialPath.move(to: center)
        initialPath.addArc(withCenter: center, radius: self.radius, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
        initialPath.addArc(withCenter: center, radius: self.radius + self.lineWidth, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
        initialPath.usesEvenOddFillRule = true
        
        maskLayer.path = initialPath.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        self.backgroundView.layer.mask = maskLayer
        
        var outerRadius: CGFloat
        let width = self.bounds.width / 2
        let height = self.bounds.width / 2
        if (width < height) {
            outerRadius = height * 1.5
        } else {
            outerRadius = width * 1.5
        }
        
        let finalPath = UIBezierPath(rect: self.backgroundView.bounds)
        finalPath.move(to: center)
        finalPath.addArc(withCenter: center, radius: 0.0, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
        finalPath.addArc(withCenter: center, radius: outerRadius, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
        finalPath.usesEvenOddFillRule = true
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate = self
        animation.toValue = finalPath.cgPath
        animation.duration = 1.0
        animation.beginTime = CACurrentMediaTime() + 0.4
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        maskLayer.add(animation, forKey: "path")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let callback = self.animationDidStopBlock {
            callback()
        }
 
        self.backgroundView.layer.mask = nil
        self.isHidden = true
    }
}
