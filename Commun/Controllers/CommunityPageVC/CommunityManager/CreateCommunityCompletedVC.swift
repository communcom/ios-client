//
//  CreateCommunityCompletedVC.swift
//  Commun
//
//  Created by Chung Tran on 9/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreateCommunityCompletedVC: BottomFlexibleHeightVC {
    lazy var manageCommunityButton = CommunButton.default(height: 50, label: "manage community".localized().uppercaseFirst, cornerRadius: 25)
    lazy var laterButton: UIButton = {
        let button = UIButton(height: 50, label: "later".localized().uppercaseFirst, backgroundColor: .appWhiteColor, textColor: .appBlackColor, cornerRadius: 25)
        button.addTarget(self, action: #selector(closeButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        closeButton.isHidden = true
        
        let label = UILabel.with(textSize: 15, weight: .bold, numberOfLines: 0, textAlignment: .center)
        label.attributedText = NSMutableAttributedString()
            .text("😎", size: 32)
            .text("\n")
            .text("\n")
            .text("Woahhh!", size: 21, weight: .bold)
            .text("\n")
            .text("\n")
            .text("now you have a leaders in your community to make some changes and vote for them!".localized().uppercaseFirst, size: 15, weight: .bold, color: .appGrayColor)
            .text("\n")
            .text("\n")
            .text("read more about".localized().uppercaseFirst, size: 15, weight: .bold, color: .appGrayColor)
            .text(" ")
            .text("community management".localized().uppercaseFirst, size: 15, weight: .bold, color: .appMainColor)
            
        let stackView = UIStackView(axis: .vertical, spacing: 30, alignment: .fill, distribution: .fill)
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10))
        stackView.addArrangedSubviews([label, manageCommunityButton, laterButton])
        
        stackView.setCustomSpacing(10, after: manageCommunityButton)
    }
}
