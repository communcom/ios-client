//
//  CommunButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunButton: UIButton {
    enum AnimationType {
        case `default`
        case upVote
        case downVote
    }
    
    static func `default`(height: CGFloat = 35, label: String? = nil) -> CommunButton {
        let button = CommunButton(height: height * Config.widthRatio, label: label, labelFont: .boldSystemFont(ofSize: 15 * Config.widthRatio), backgroundColor: .appMainColor, textColor: .white, cornerRadius: height * Config.widthRatio / 2, contentInsets: UIEdgeInsets(top: 10 * Config.widthRatio, left: 16 * Config.widthRatio, bottom: 10 * Config.widthRatio, right: 14 * Config.widthRatio))
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }
    
    func setHightLight(_ isHighlighted: Bool, highlightedLabel: String, unHighlightedLabel: String) {
        backgroundColor = isHighlighted ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        setTitleColor(isHighlighted ? .appMainColor: .white , for: .normal)
        setTitle((isHighlighted ? highlightedLabel : unHighlightedLabel).localized().uppercaseFirst, for: .normal)
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1: 0.5
        }
    }
    
    func animate(type: AnimationType = .default, completion: (()->Void)? = nil) {
        switch type {
        case .default:
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            
            let moveDownAnim = CABasicAnimation(keyPath: "transform.scale")
            moveDownAnim.byValue = 1.2
            moveDownAnim.autoreverses = true
            layer.add(moveDownAnim, forKey: "transform.scale")
            
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.byValue = -1
            fadeAnim.autoreverses = true
            layer.add(fadeAnim, forKey: "Fade")
            
            CATransaction.commit()
        case .upVote:
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)

            let moveUpAnim = CABasicAnimation(keyPath: "position.y")
            moveUpAnim.byValue = -16
            moveUpAnim.autoreverses = true
            layer.add(moveUpAnim, forKey: "moveUp")

            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.byValue = -1
            fadeAnim.autoreverses = true
            layer.add(fadeAnim, forKey: "Fade")

            CATransaction.commit()
        case .downVote:
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            
            let moveDownAnim = CABasicAnimation(keyPath: "position.y")
            moveDownAnim.byValue = 16
            moveDownAnim.autoreverses = true
            layer.add(moveDownAnim, forKey: "moveDown")
            
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.byValue = -1
            fadeAnim.autoreverses = true
            layer.add(fadeAnim, forKey: "Fade")
            
            CATransaction.commit()
        }
    }
}
