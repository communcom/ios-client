//
//  UIButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import PureLayout
import CyberSwift

extension UIButton {
    public convenience init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        label: String? = nil,
        labelFont: UIFont? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        contentInsets: UIEdgeInsets? = nil,
        completionDisable: (() -> Void)? = nil
    ) {
        self.init(width: width, height: height, backgroundColor: backgroundColor)
        
        setTitle(label, for: .normal)
        
        if let font = labelFont {
            titleLabel?.font = font
        }
        
        if let textColor = textColor {
            setTitleColor(textColor, for: .normal)
        }
        
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        
        if let contentInsets = contentInsets {
            if contentInsets == .zero {
                // After some experimentation, it appears that if you try and set contentEdgeInsets to all zeros, the default insets are used. However, if you set them to nearly zero, it works:
                contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0)
            } else {
                contentEdgeInsets = contentInsets
            }
        }
    }
    
    static func roundedCorner(
        _ cornerRadius: CGFloat,
        size: CGFloat,
        backgroundColor: UIColor,
        tintColor: UIColor? = nil,
        imageName: String,
        imageEdgeInsets: UIEdgeInsets? = nil
    ) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
        button.setImage(UIImage(named: imageName), for: .normal)
        if let imageEdgeInsets = imageEdgeInsets {
            button.imageEdgeInsets = imageEdgeInsets
        }
        if let tintColor = tintColor {
            button.tintColor = tintColor
        }
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func circle(
        size: CGFloat,
        backgroundColor: UIColor,
        tintColor: UIColor? = nil,
        imageName: String,
        imageEdgeInsets: UIEdgeInsets? = nil
    ) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: backgroundColor, cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        if let imageEdgeInsets = imageEdgeInsets {
            button.imageEdgeInsets = imageEdgeInsets
        }
        if let tintColor = tintColor {
            button.tintColor = tintColor
        }
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func circleGray(size: CGFloat = 24, imageName: String, imageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: .appLightGrayColor, cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageEdgeInsets = imageEdgeInsets
        button.tintColor = .appGrayColor
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }

    static func close(size: CGFloat = 24, imageName: String = "close-x", backgroundColor: UIColor = .appLightGrayColor, tintColor: UIColor = .appGrayColor) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: backgroundColor, cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = tintColor
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func circleBlack(size: CGFloat = 24, imageName: String) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: .black, cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.tintColor = .appWhiteColor
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func back(width: CGFloat = 43, height: CGFloat = 44, tintColor: UIColor = .appBlackColor, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 31)) -> UIButton {
        let button = UIButton(width: width, height: height)
        button.tintColor = tintColor
        button.setImage(UIImage(named: "left-arrow"), for: .normal)
        button.contentEdgeInsets = contentInsets
        button.touchAreaEdgeInsets = UIEdgeInsets(top: 0, left: -9.5, bottom: 0, right: 0)
        return button
    }
    
    static func option(tintColor: UIColor = .appBlackColor, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)) -> UIButton {
        let button = UIButton(width: 36, height: 40, contentInsets: contentInsets)
        button.tintColor = tintColor
        button.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -2)
        button.contentEdgeInsets = contentInsets
        return button
    }
    
    static func vote(type: VoteActionType) -> UIButton {
        let button = UIButton(width: 38)
        button.imageEdgeInsets = UIEdgeInsets(top: 10.5, left: type == .upvote ? 10 : 18, bottom: 10.5, right: type == .upvote ? 18: 10)
        button.setImage(UIImage(named: type == .upvote ? "upVote" : "downVote"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -3)
        return button
    }
}
