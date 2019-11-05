//
//  LeaderAvatarImageView.swift
//  Commun
//
//  Created by Chung Tran on 11/5/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class LeaderAvatarImageView: MyAvatarImageView {
    // MARK: - Constants
    let numberOfPieces = 8
    let arcSpaceAngle: CGFloat = 15 * CGFloat.pi / 180
    var arcAngle: CGFloat {
        (2 * CGFloat.pi - CGFloat(numberOfPieces) * arcSpaceAngle) / CGFloat(numberOfPieces)
    }
    let arcWidth: CGFloat = 3
    override var imageViewInsets: UIEdgeInsets { UIEdgeInsets(inset: arcWidth * 2)}
    
    // MARK: - Properties
    var percent: Double? {
        didSet {
            drawRatingPercent()
        }
    }
    
    var percentLayers = [CAShapeLayer]()
    
    // MARK: - Methods
    func drawRatingPercent() {
        guard let percent = percent else {return}
        // clean
        for layer in percentLayers {
            layer.removeFromSuperlayer()
        }
        percentLayers = []
        
        // get angle
        let angle = CGFloat(percent) * CGFloat.pi
        
        let rect = CGRect(x: 0, y: 0, width: originSize, height: originSize)
        for i in 0..<numberOfPieces {
            let path = UIBezierPath()
            let startAngle: CGFloat = -CGFloat.pi / 2 + CGFloat(i) * (arcSpaceAngle + arcAngle) + arcSpaceAngle / 2
            let endAngle: CGFloat = startAngle + arcAngle
            path.addArc(withCenter: CGPoint(x: originSize / 2, y: originSize / 2), radius: rect.width / 2 - arcWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            let percentLayer = CAShapeLayer()
            percentLayer.strokeColor = UIColor.appMainColor.cgColor
            percentLayer.fillColor = UIColor.clear.cgColor
            percentLayer.lineWidth = arcWidth
            percentLayer.lineJoin = .round
            percentLayer.lineCap = .round
            percentLayer.path = path.cgPath
            percentLayers.append(percentLayer)
        }
        
        for percentLayer in percentLayers {
            layer.addSublayer(percentLayer)
        }
    }
}
