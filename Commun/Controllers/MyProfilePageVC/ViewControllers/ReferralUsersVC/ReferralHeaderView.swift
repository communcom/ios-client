//
//  ReferralHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReferralHeaderView: MyTableHeaderView {
    lazy var learnMoreButton = UIButton(width: 18, height: 18)
    
    lazy var shareButton = CommunButton.default(height: 34, label: "share".localized().uppercaseFirst, isHuggingContent: false)
    lazy var copyButton = CommunButton.default(height: 34, label: "copy".localized().uppercaseFirst, isHuggingContent: false)
    
    override func commonInit() {
        super.commonInit()
        
        let containerView = UIView(backgroundColor: .white, cornerRadius: 16)
        addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let imageView = UIImageView(width: 140, height: 140, imageNamed: "referral-coin")
        containerView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        let userIdLabel = UILabel.with(text: Config.currentUser?.id?.uppercased(), textSize: 24, weight: .semibold)
        
        containerView.addSubview(userIdLabel)
        userIdLabel.autoPinTopAndLeadingToSuperView(inset: 16, xInset: 20)
        
        learnMoreButton.setImage(UIImage(named: "referral-info"), for: .normal)
        containerView.addSubview(learnMoreButton)
        learnMoreButton.autoPinEdge(.leading, to: .trailing, of: userIdLabel, withOffset: 10)
        learnMoreButton.autoAlignAxis(.horizontal, toSameAxisOf: userIdLabel)
        
        let descriptionLabel = UILabel.with(text: "invite a friend and get 1 Commun when he signs up".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd, numberOfLines: 0)
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: userIdLabel, withOffset: 6)
        descriptionLabel.autoPinEdge(.trailing, to: .leading, of: imageView)
        
        let buttonsStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fillEqually)
        
        buttonsStackView.addArrangedSubviews([shareButton, copyButton])
        
        containerView.addSubview(buttonsStackView)
        buttonsStackView.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 10)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        buttonsStackView.autoPinEdge(.trailing, to: .leading, of: imageView)
        
        let yourReferralsLabel = UILabel.with(text: "your referrals".localized().uppercaseFirst, textSize: 20, weight: .bold)
        addSubview(yourReferralsLabel)
        yourReferralsLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 16, right: 10), excludingEdge: .top)
        yourReferralsLabel.autoPinEdge(.top, to: .bottom, of: containerView, withOffset: 20)
    }
}
