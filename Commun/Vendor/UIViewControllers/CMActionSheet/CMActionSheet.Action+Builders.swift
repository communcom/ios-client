//
//  CMActionSheet.Action + Extensions.swift
//  Commun
//
//  Created by Chung Tran on 8/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension CMActionSheet.Action {
    static func `default`(title: String, showIcon: Bool = true, iconName: String? = nil, tintColor: UIColor = .appBlackColor, handle: (() -> Void)?, bottomMargin: CGFloat? = 10) -> CMActionSheet.Action {
        customLayout(height: 50, title: title, textSize: 15, textColor: tintColor, spacing: 10, showIcon: showIcon, iconName: iconName, iconSize: 24, iconTintColor: tintColor, showIconFirst: false, showNextButton: false, bottomMargin: bottomMargin, handle: handle)
    }
    
    static func iconFirst(title: String, iconName: String, handle: (() -> Void)?, bottomMargin: CGFloat? = nil, showNextButton: Bool = false) -> CMActionSheet.Action {
        customLayout(height: 65, title: title, textSize: 17, spacing: 10, iconName: iconName, iconSize: 35, showIconFirst: true, showNextButton: showNextButton, bottomMargin: bottomMargin, handle: handle)
    }
    
    static func customLayout(height: CGFloat = 50, padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), title: String, textSize: CGFloat = 15, textColor: UIColor = .appBlackColor, spacing: CGFloat = 10, showIcon: Bool = true, iconName: String? = nil, iconSize: CGFloat = 24, iconTintColor: UIColor? = nil, showIconFirst: Bool = false, showNextButton: Bool = false, bottomMargin: CGFloat? = nil, handle: (() -> Void)?) -> CMActionSheet.Action {
        let stackView = UIStackView(axis: .horizontal, spacing: spacing, alignment: .center, distribution: .fill)
        let label = UILabel.with(text: title, textSize: textSize, weight: .medium, textColor: textColor)
        let iconImageView = UIImageView(width: iconSize, height: iconSize, imageNamed: iconName)
        if let iconTintColor = iconTintColor {
            iconImageView.tintColor = iconTintColor
        }
        if !showIcon { stackView.addArrangedSubviews([label]) }
        else if showIconFirst { stackView.addArrangedSubviews([iconImageView, label]) }
        else {stackView.addArrangedSubviews([label, iconImageView])}
        
        if showNextButton {
            let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
            nextButton.isUserInteractionEnabled = false
            stackView.addArrangedSubview(nextButton)
        }
        
        let view = UIView(height: height, backgroundColor: .appWhiteColor)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        return CMActionSheet.Action(view: view, handle: handle, bottomMargin: bottomMargin)
    }
}
