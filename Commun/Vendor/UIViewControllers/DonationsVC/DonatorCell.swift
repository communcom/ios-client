//
//  DonatorCell.swift
//  Commun
//
//  Created by Chung Tran on 6/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DonatorCell: SubscribersCell {
    lazy var detailLabel = UILabel.with(textSize: 15, numberOfLines: 2, textAlignment: .right)
    
    override func setUpViews() {
        super.setUpViews()
        hideActionButton()
        
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        stackView.addArrangedSubview(detailLabel)
        
        showFollowersFollowings = false
    }
    
    func setUp(with donation: ResponseAPIWalletDonation, pointType: String) {
        setUp(with: donation.sender)
        detailLabel.attributedText = NSMutableAttributedString()
            .text("\(donation.quantity) \(pointType)", size: 15, weight: .semibold, color: .appGreenColor)
    }
}
