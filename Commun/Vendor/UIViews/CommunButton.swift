//
//  CommunButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommunButton: UIButton {
    var isDisableGrayColor = false
    
    var isDisabled: Bool = false {
        didSet {
            if isDisableGrayColor {
                backgroundColor = isDisabled ? .appGrayColor : .appMainColor
            }
            alpha = isDisabled ? 0.5 : 1
        }
    }

    override var isEnabled: Bool {
        didSet {
            if isDisableGrayColor {
                backgroundColor = isEnabled ? UIColor.appMainColor : .appGrayColor
            }
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    enum AnimationType {
        case `default`
        case upVote
        case downVote
    }
    
    static func `default`(height: CGFloat = 35.0, label: String? = nil, cornerRadius: CGFloat? = nil, isHuggingContent: Bool = true, isDisableGrayColor: Bool = false, isDisabled: Bool = false) -> CommunButton {
        let button = CommunButton(height: height,
                                  label: label,
                                  labelFont: .boldSystemFont(ofSize: 15.0),
                                  backgroundColor: .appMainColor,
                                  textColor: .white,
                                  cornerRadius: cornerRadius ?? height / 2,
                                  contentInsets: UIEdgeInsets(top: 10.0,
                                                                 left: 15.0,
                                                                 bottom: 10.0,
                                                                 right: 15.0))

        button.isDisabled = isDisabled
        button.isDisableGrayColor = isDisableGrayColor

        if isHuggingContent {
            button.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        return button
    }
    
    func setHightLight(_ isHighlighted: Bool, highlightedLabel: String, unHighlightedLabel: String) {
        backgroundColor = isHighlighted ? .appLightGrayColor : .appMainColor
        setTitleColor(isHighlighted ? .appMainColor: .white, for: .normal)
        setTitle((isHighlighted ? highlightedLabel : unHighlightedLabel).localized().uppercaseFirst, for: .normal)
    }
    
    func animate(type: AnimationType = .default, completion: (() -> Void)? = nil) {
        switch type {
        case .default:
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)

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

extension Reactive where Base: CommunButton {
    /// Bindable sink for `disabled` property.
    var isDisabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isDisabled = !value
        }
    }
}
