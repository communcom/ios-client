//
//  RightAlignedIconButton.swift
//  Commun
//
//  Created by Chung Tran on 11/9/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class RightAlignedIconButton: UIButton {
    var textToImageSpace: CGFloat
    init(
        imageName: String,
        label: String? = nil,
        labelFont: UIFont? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        contentInsets: UIEdgeInsets? = nil,
        textToImageSpace: CGFloat = 10
    ) {
        self.textToImageSpace = textToImageSpace
        super.init(frame: .zero)
        configureForAutoLayout()
        setImage(UIImage(named: imageName), for: .normal)
        setTitle(label, for: .normal)
        if let font = labelFont {
            titleLabel?.font = font
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let textColor = textColor {
            setTitleColor(textColor, for: .normal)
        }
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        if let contentInsets = contentInsets {
            self.contentEdgeInsets = contentInsets
        }
        semanticContentAttribute = .forceRightToLeft
        contentHorizontalAlignment = .right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let availableSpace = bounds.inset(by: contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.left - imageEdgeInsets.right - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -textToImageSpace * 2, bottom: 0, right: availableWidth / 2 + textToImageSpace)
    }
}

class LeftAlignedIconButton: UIButton {
    var textToImageSpace: CGFloat = 4
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHorizontalAlignment = .left
        let availableSpace = bounds.inset(by: contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.right - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: availableWidth / 2 + textToImageSpace, bottom: 0, right: -textToImageSpace)
    }
}
