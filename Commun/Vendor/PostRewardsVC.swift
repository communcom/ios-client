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
    var donateButtonHandler: (() -> Void)?
    
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
        
        let donatersLabel = UILabel.with(textSize: 20, weight: .bold)
        donatersLabel.attributedText = NSMutableAttributedString()
            .text("donators".localized().uppercaseFirst, size: 20, weight: .bold)
            .text(" ")
            .text("\(post.donations?.donators.count ?? 0)", size: 20, weight: .bold, color: .appGrayColor)
        stackView.insertArrangedSubview(donatersLabel.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)), at: 1)
        
        stackView.setCustomSpacing(20, after: headerView)
        stackView.setCustomSpacing(0, after: donatersLabel)
        
        postMetaView.setUp(post: post)
        rewardsLabel.attributedText = NSMutableAttributedString()
            .text(post.mosaic?.formatedRewardsValue ?? "0", size: 15, weight: .semibold)
            .text("\n")
            .text("rewards".localized().uppercaseFirst, size: 12, weight: .medium, color: .appGrayColor)
            
        donationsLabel.attributedText = NSMutableAttributedString()
            .text(post.donationsCount.currencyValueFormatted, size: 15, weight: .semibold)
            .text("\n")
            .text("donations".localized().uppercaseFirst, size: 12, weight: .medium, color: .appGrayColor)
        
        donateButton.addTarget(self, action: #selector(donateButtonDidTouch), for: .touchUpInside)
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
        
        let rewardsStackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let rewardsImageView = UIImageView(width: 35, height: 35, imageNamed: "rewards-cup")
        let donationImageView = UIImageView(width: 35, height: 35, imageNamed: "rewards-coin")
        
        rewardsImageView.setContentHuggingPriority(.required, for: .horizontal)
        rewardsLabel.setContentHuggingPriority(.required, for: .horizontal)
        donationImageView.setContentHuggingPriority(.required, for: .horizontal)
        donationsLabel.setContentHuggingPriority(.required, for: .horizontal)
        donateButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rewardsStackView.addArrangedSubviews([rewardsImageView, rewardsLabel, donationImageView, donationsLabel, donateButton])
        
        view.addSubview(rewardsStackView)
        rewardsStackView.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 16)
        rewardsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        rewardsStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        rewardsStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        return view
    }
    
    @objc func donateButtonDidTouch() {
        donateButtonHandler?()
    }
}
