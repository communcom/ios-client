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
    lazy var joinButton = CommunButton.default(label: "follow".localized().uppercaseFirst)

    lazy var friendLabel = UILabel.with(text: "friends".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .a5a7bd)

    lazy var membersCountLabel = UILabel.with(text: 10000000.kmFormatted, textSize: 15, weight: .bold)
    
    lazy var leadersCountLabel = UILabel.with(text: "7", textSize: 15, weight: .bold)
    
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
        
        addSubview(joinButton)
        joinButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        joinButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch(_:)), for: .touchUpInside)
        
        joinedDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -8)
            .isActive = true
        
        addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 24)
        membersCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: usersStackView)

        let membersButton = UIButton()
        addSubview(membersButton)
        membersButton.autoPinEdge(.left, to: .left, of: membersCountLabel)
        membersButton.autoPinEdge(.top, to: .top, of: membersCountLabel, withOffset: -10)
        membersButton.autoPinEdge(.bottom, to: .bottom, of: membersCountLabel, withOffset: 10)
        membersButton.autoPinEdge(.right, to: .right, of: membersCountLabel)
        membersButton.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)
        membersButton.addTarget(self, action: #selector(membersLabelDidTouch), for: .touchUpInside)

        let dotLabel = UILabel.with(text: "•", textSize: 15.0, weight: .semibold, textColor: .a5a7bd)
        addSubview(dotLabel)
        dotLabel.autoPinEdge(.leading, to: .trailing, of: membersCountLabel, withOffset: 2)
        dotLabel.autoPinEdge(.bottom, to: .bottom, of: membersCountLabel, withOffset: 2)

        addSubview(leadersCountLabel)
        leadersCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel, withOffset: 2)
        leadersCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)

        let leadersButton = UIButton()
        addSubview(leadersButton)
        leadersButton.autoPinEdge(.left, to: .left, of: leadersCountLabel)
        leadersButton.autoPinEdge(.top, to: .top, of: leadersCountLabel, withOffset: -10)
        leadersButton.autoPinEdge(.bottom, to: .bottom, of: leadersCountLabel, withOffset: 10)
        leadersButton.autoPinEdge(.right, to: .right, of: leadersCountLabel)
        leadersButton.autoAlignAxis(.horizontal, toSameAxisOf: leadersCountLabel)
        leadersButton.addTarget(self, action: #selector(leadsLabelDidTouch), for: .touchUpInside)

        addSubview(friendLabel)
        friendLabel.autoAlignAxis(.horizontal, toSameAxisOf: usersStackView)
        friendLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        friendLabel.autoPinEdge(.leading, to: .trailing, of: usersStackView, withOffset: 5)
        friendLabel.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(friendsLabelDidTouch))
        friendLabel.addGestureRecognizer(tap3)
        
        addSubview(pointsContainerView)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        pointsContainerView.autoPinEdge(.top, to: .bottom, of: membersCountLabel, withOffset: 22)
        
        pointsContainerView.addShadow(ofColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 0.3),
                                      radius: 24,
                                      offset: CGSize(width: 0.0, height: 14),
                                      opacity: 1.0)

        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: pointsContainerView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        let separator = UIView(height: 10, backgroundColor: .appLightGrayColor)
        addSubview(separator)
        
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leaders".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
    }
    
    // ResponseAPIWalletGetPrice(price: "647.654 BIKE", symbol: Optional("BIKE"), quantity: Optional("10 CMN"))
    func setUp(walletPrice: ResponseAPIWalletGetPrice) {
        walletCurrencyValue.text = walletPrice.price.components(separatedBy: " ").first ?? "0.0" // 1000
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
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        
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
        
        if let description = community.description {
            if description.count <= 180 {
                descriptionLabel.text = description
            } else {
                descriptionLabel.text = String(description.prefix(177)) + "..."
            }
        }
        
        // membersCount
        let aStr = NSMutableAttributedString()
            .bold((community.subscribersCount ?? 0).kmFormatted, font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold("members".localized().uppercaseFirst, font: .boldSystemFont(ofSize: 12), color: .a5a7bd)
        
        membersCountLabel.attributedText = aStr
        
        // leadsCount
        let aStr2 = NSMutableAttributedString()
            .bold("\((community.leadersCount ?? 0).kmFormatted)", font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold("leaders".localized().uppercaseFirst, font: .boldSystemFont(ofSize: 12), color: .a5a7bd)
        leadersCountLabel.attributedText = aStr2
        
        // friends
        if let friends = community.friends, friends.count > 0 {
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
