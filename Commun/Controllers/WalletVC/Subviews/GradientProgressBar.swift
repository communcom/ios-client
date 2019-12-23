//
//  GradientProgressBar.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class GradientProgressBar: MyView {
    // MARK: - Properties
    var drawedBackground = false
    var progress: CGFloat = 0 {
        didSet {
            layoutIfNeeded()
            animate()
        }
    }
    
    // MARK: - Sublayers
    lazy var progressLayer = CAShapeLayer()
    
    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        if !drawedBackground {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: bounds.width, y: height / 2))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
            shapeLayer.lineWidth = height
            shapeLayer.lineJoin = .round
            shapeLayer.lineCap = .round
            layer.addSublayer(shapeLayer)
            layer.addSublayer(shapeLayer)
            drawedBackground = true
        }
        
        if progressLayer.superlayer == nil {
            // draw progress
            progressLayer.strokeColor = UIColor.red.cgColor
            progressLayer.lineWidth = height - 2 * 2
            progressLayer.lineJoin = .round
            progressLayer.lineCap = .round
            progressLayer.path = createPath().cgPath
            layer.addSublayer(progressLayer)
        }
    }
    
    private func createPath() -> UIBezierPath {
        let newX = (bounds.width - 2 * 2) * progress + 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 2, y: height / 2))
        path.addLine(to: CGPoint(x: newX, y: height / 2))
        return path
    }
    
    private func animate() {
        let newShapePath = createPath().cgPath
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
        animation.toValue = newShapePath
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        progressLayer.add(animation, forKey: "path")
    }
}

extension GradientProgressBar: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            progressLayer.path = createPath().cgPath
        }
    }
}
