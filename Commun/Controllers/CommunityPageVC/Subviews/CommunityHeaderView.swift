//
//  CommunityHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommunityHeaderView: ProfileHeaderView, CommunityController {
    // MARK: - CommunityController
    var community: ResponseAPIContentGetCommunity?
    
    // MARK: - Subviews
    lazy var pointsContainerView: UIView = {
        let view = UIView(height: 70, backgroundColor: .appMainColor)
        view.cornerRadius = 10
        
        view.addSubview(walletImageView)
        walletImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        walletImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addSubview(walletCurrencyValue)
        walletCurrencyValue.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        walletCurrencyValue.autoPinEdge(.top, to: .top, of: walletImageView, withOffset: 2.0)
        
        view.addSubview(walletCurrencyLabel)
        walletCurrencyLabel.autoPinEdge(.leading, to: .trailing, of: walletCurrencyValue, withOffset: 4.0)
        walletCurrencyLabel.autoPinEdge(.bottom, to: .bottom, of: walletCurrencyValue, withOffset: -1.0)
        
        let equalLabel = UILabel.with(text: "=", textSize: 12, weight: .semibold, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        equalLabel.alpha = 0.7
        
        view.addSubview(equalLabel)
        equalLabel.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        equalLabel.autoPinEdge(.bottom, to: .bottom, of: walletImageView, withOffset: -2.0)
        
        view.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(.leading, to: .trailing, of: equalLabel, withOffset: 2)
        communValueLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        
        let communLabel = UILabel.with(text: "Commun", textSize: 12, weight: .semibold, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        communLabel.alpha = 0.7
        
        view.addSubview(communLabel)
        communLabel.autoPinEdge(.leading, to: .trailing, of: communValueLabel, withOffset: 2)
        communLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        
        view.addSubview(walletButton)
        walletButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        walletButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addShadow(ofColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 0.3), radius: 24, offset: CGSize(width: 0.0, height: 14), opacity: 1.0)
        
        return view
    }()
    
    lazy var walletImageView: UIImageView = {
        let imageView = UIImageView(width: 40, height: 40, backgroundColor: .clear)
        imageView.cornerRadius = 20
        imageView.image = UIImage(named: "community-wallet")
        
        return imageView
    }()
    
    lazy var walletCurrencyValue: UILabel = {
        let label = UILabel.with(text: "1000", textSize: 15, weight: .semibold, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        label.isHidden = true

        return label
    }()
    
    lazy var walletCurrencyLabel: UILabel = {
        let label = UILabel.with(text: "Binance", textSize: 12, weight: .semibold, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        label.isHidden = true
        label.alpha = 0.7

        return label
    }()
    
    lazy var communValueLabel: UILabel = {
        let label = UILabel.with(text: "10", textSize: 12, weight: .bold, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        label.alpha = 0.7
        
        return label
    }()
    
    lazy var walletButton: UIButton = {
        let button = UIButton(width: 99,
                              height: 35,
                              label: "get points".localized().uppercaseFirst,
                              labelFont: UIFont.systemFont(ofSize: 15, weight: .medium),
                              backgroundColor: .white,
                              textColor: .appMainColor,
                              cornerRadius: 12.5)
        return button
    }()
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        let friendLabel = UILabel.with(text: "friends".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .a5a7bd)
        statsStackView.addArrangedSubview(friendLabel)
        
        stackView.addArrangedSubviews([
            headerStackView,
            descriptionLabel,
            pointsContainerView,
            segmentedControl,
            separator
        ])
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leaders".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
    }
    
    // ResponseAPIWalletGetPrice(price: "647.654 BIKE", symbol: Optional("BIKE"), quantity: Optional("10 CMN"))
    func setUp(walletPrice: ResponseAPIWalletGetPrice) {
        walletCurrencyValue.text = walletPrice.priceValue.string
        walletCurrencyLabel.text = (walletPrice.symbol ?? "Commun").lowercased().uppercaseFirst // "Binance"
        walletCurrencyValue.isHidden = false
        walletCurrencyLabel.isHidden = false
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        
        if self.community?.isInBlacklist == true {
            self.community?.isSubscribed = false
        }
        
        // avatar
        if let avatarURL = community.avatarUrl {
            avatarImageView.setAvatar(urlString: avatarURL)
            avatarImageView.addTapToViewer(with: avatarURL)
        }
        
        // name
        nameLabel.text = community.name
        
        // joined date
        joinedDateLabel.text = Formatter.joinedText(with: community.registrationTime)

        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.setHightLight(joined, highlightedLabel: "following", unHighlightedLabel: "follow")
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
        
        // notification button
        if let trailingConstraint = nameLabel.constraints.first(where: {$0.firstAttribute == .trailing}) {
            nameLabel.removeConstraint(trailingConstraint)
        }
        
        nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -8)
            .isActive = true
        
        // description
        descriptionLabel.text = nil
        
        // ticket #909
        /*
        if let description = community.description {
            if description.count <= 180 {
                descriptionLabel.text = description
            } else {
                descriptionLabel.text = String(description.prefix(177)) + "..."
            }
        }
        */
        
        // membersCount
        let membersCount: Int64 = community.subscribersCount ?? 0
        let aStr = NSMutableAttributedString()
            .bold(membersCount.kmFormatted, font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("members-count", comment: ""), membersCount), font: .boldSystemFont(ofSize: 12), color: .a5a7bd)
        
        membersCountLabel.attributedText = aStr
        
        // leadsCount
        let leadersCount: Int64 = community.leadersCount ?? 0
        let aStr2 = NSMutableAttributedString()
            .bold("\(leadersCount.kmFormatted)", font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("leaders-count", comment: ""), leadersCount), font: .boldSystemFont(ofSize: 12), color: .a5a7bd)
        leadersCountLabel.attributedText = aStr2

        // friends
        if let friends = community.friends, friends.count > 0 {
            let count = friends.count > 3 ? friends.count - 3 : friends.count
            friendLabel.text = String(format: NSLocalizedString("friend-count", comment: ""), count)
            usersStackView.setUp(with: friends)
            friendLabel.isHidden = false
        } else {
            friendLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc func joinButtonDidTouch(_ button: UIButton) {
        toggleJoin()
    }
    
    @objc func membersLabelDidTouch() {
        guard let community = community else {return}
        let vc = CommunityMembersVC(community: community, selectedSegmentedItem: .all)
        parentViewController?.show(vc, sender: nil)
    }
    
    @objc func friendsLabelDidTouch() {
        guard let community = community else {return}
        let vc = CommunityMembersVC(community: community, selectedSegmentedItem: .friends)
        parentViewController?.show(vc, sender: nil)
    }
    
    @objc func leadsLabelDidTouch() {
        if segmentedControl.selectedIndex.value == 1 {
            parentViewController?.view.shake()
        } else {
            segmentedControl.changeSelectedIndex(1)
        }
    }
}
