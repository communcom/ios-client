//
//  PostRewardsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class PostRewardsVC: DonationsVC {
    // MARK: - Properties
    let post: ResponseAPIContentGetPost
    
    // MARK: - Subviews
    lazy var postMetaView: PostMetaView = {
        let postMetaView = PostMetaView(forAutoLayout: ())
        postMetaView.showMosaic = false
        return postMetaView
    }()
    lazy var rewardsLabel = UILabel.with(textSize: 14, numberOfLines: 2)
    lazy var donationsLabel = UILabel.with(textSize: 14, numberOfLines: 2)
    lazy var donateButton = UIButton(height: 35, label: "donate".localized().uppercaseFirst, backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    
    // MARK: - Initializers
    init?(post: ResponseAPIContentGetPost) {
        self.post = post
        guard let donations = post.donations else {return nil}
        super.init(donations: donations)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        let headerView = setUpHeaderView()
        stackView.insertArrangedSubview(headerView, at: 0)
        
        postMetaView.setUp(post: post)
        rewardsLabel.attributedText = NSMutableAttributedString()
            .text(post.mosaic?.formatedRewardsValue ?? "0", size: 15, weight: .semibold)
            .text("\n")
            .text("rewards".localized().uppercaseFirst, size: 12, weight: .medium, color: .appGrayColor)
            
        donationsLabel.attributedText = NSMutableAttributedString()
            .text(post.donationsCount.currencyValueFormatted, size: 15, weight: .semibold)
            .text("\n")
            .text("donations".localized().uppercaseFirst, size: 12, weight: .medium, color: .appGrayColor)
    }
    
    private func setUpHeaderView() -> UIView {
        let view = UIView(backgroundColor: .white)
        view.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: 16)
        
        view.addSubview(postMetaView)
        postMetaView.autoPinTopAndLeadingToSuperView(inset: 16)
        
        postMetaView.autoPinEdge(.trailing, to: .leading, of: closeButton, withOffset: 10)
        
        let separator = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        view.addSubview(separator)
        separator.autoPinEdge(.top, to: .bottom, of: postMetaView, withOffset: 16)
        separator.autoPinEdge(toSuperviewEdge: .leading)
        separator.autoPinEdge(toSuperviewEdge: .trailing)
        
        let rewardsStackView = UIStackView(axis: .horizontal, spacing: 2, alignment: .center, distribution: .equalSpacing)
        let rewardWrapper = createRewardsWrapper(iconNamed: "rewards-cup", label: rewardsLabel)
        let donationWrapper = createRewardsWrapper(iconNamed: "rewards-coin", label: donationsLabel)
        
        donateButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rewardsStackView.addArrangedSubviews([rewardWrapper, donationWrapper, donateButton])
        
        view.addSubview(rewardsStackView)
        rewardsStackView.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 16)
        rewardsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        rewardsStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        rewardsStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        return view
    }
    
    private func createRewardsWrapper(iconNamed: String, label: UILabel) -> UIStackView {
        let view = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let imageView = UIImageView(width: 35, height: 35, imageNamed: iconNamed)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        view.addArrangedSubviews([imageView, label])
        return view
    }
}
