//
//  UIButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
        contentInsets: UIEdgeInsets? = nil
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
            contentEdgeInsets = contentInsets
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
    
    static func circleGray(size: CGFloat = 24, imageName: String) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: UIColor(hexString: "#F7F7F9"), cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.tintColor = UIColor(hexString: "#A5A7BD")
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }

    static func close(size: CGFloat = 24, imageName: String = "close-x") -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: UIColor(hexString: "#F3F5FA"), cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .appGrayColor
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func circleBlack(size: CGFloat = 24, imageName: String) -> UIButton {
        let button = UIButton(width: size, height: size, backgroundColor: UIColor(hexString: "#000000"), cornerRadius: size / 2)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.tintColor = .white
        if size < 44 {
            button.touchAreaEdgeInsets = UIEdgeInsets(inset: (size - 44) / 2)
        }
        return button
    }
    
    static func back(tintColor: UIColor = .black, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 11, left: 15, bottom: 11, right: 14)) -> UIButton {
        let button = UIButton(width: 40, height: 40)
        button.tintColor = tintColor
        button.setImage(UIImage(named: "back-button"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -2)
        button.contentEdgeInsets = contentInsets
        return button
    }
    
    static func option(tintColor: UIColor = .black, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)) -> UIButton {
        let button = UIButton(width: 36, height: 40, contentInsets: contentInsets)
        button.tintColor = tintColor
        button.setImage(UIImage(named: "postpage-more"), for: .normal)
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
