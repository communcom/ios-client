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
    private func drawRatingPercent() {
        guard let percent = percent else {return}
        // clean
        for layer in percentLayers {
            layer.removeFromSuperlayer()
        }
        percentLayers = []
        
        // get angle
        let angle = CGFloat(percent) * CGFloat.pi * 2 - CGFloat.pi / 2
        
        
        for i in 0..<numberOfPieces {
            let startAngle: CGFloat = -CGFloat.pi / 2 + CGFloat(i) * (arcSpaceAngle + arcAngle) + arcSpaceAngle / 2
            let endAngle: CGFloat = startAngle + arcAngle
            
            if angle <= startAngle {
                let percentLayer = arcLayer(withColor: #colorLiteral(red: 0.9137254902, green: 0.9176470588, blue: 0.937254902, alpha: 1), startAngle: startAngle, endAngle: endAngle)
                percentLayers.append(percentLayer)
            }
            else if angle >= endAngle {
                let percentLayer = arcLayer(withColor: .appMainColor, startAngle: startAngle, endAngle: endAngle)
                percentLayers.append(percentLayer)
            }
            else {
                // separate
                let percentLayer1 = arcLayer(withColor: .appMainColor, startAngle: startAngle, endAngle: angle)
                percentLayers.append(percentLayer1)
                
                let percentLayer2 = arcLayer(withColor: #colorLiteral(red: 0.9137254902, green: 0.9176470588, blue: 0.937254902, alpha: 1), startAngle: angle, endAngle: endAngle)
                percentLayers.append(percentLayer2)
            }
        }
        
        for percentLayer in percentLayers {
            layer.addSublayer(percentLayer)
        }
    }
    
    private func arcLayer(withColor color: UIColor, startAngle: CGFloat, endAngle: CGFloat
    ) -> CAShapeLayer {
        let rect = CGRect(x: 0, y: 0, width: originSize, height: originSize)
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: originSize / 2, y: originSize / 2), radius: rect.width / 2 - arcWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let percentLayer = CAShapeLayer()
        percentLayer.strokeColor = color.cgColor
        percentLayer.fillColor = UIColor.clear.cgColor
        percentLayer.lineWidth = arcWidth
        percentLayer.lineJoin = .round
        percentLayer.lineCap = .round
        percentLayer.path = path.cgPath
        return percentLayer
    }
}
