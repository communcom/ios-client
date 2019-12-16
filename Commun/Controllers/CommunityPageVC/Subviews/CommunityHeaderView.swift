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
    lazy var notificationButton: UIButton = {
        // "Don't use in MVP"
        /*
        let button = UIButton(width: 35, height: 35, backgroundColor: .f3f5fa, cornerRadius: 35/2, contentInsets: UIEdgeInsets(top: 10, left: 11, bottom: 10, right: 11))
        button.tintColor = .appMainColor
        button.setImage(UIImage(named: "profilepage-notification")!, for: .normal)
        return button
        */
        return UIButton()
    }()
    
    lazy var joinButton = CommunButton.default(label: "follow".localized().uppercaseFirst)

    lazy var friendLabel = UILabel.with(text: "friends".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .a5a7bd)

    lazy var membersCountLabel: UILabel = {
        let label = UILabel.with(text: Double(10000000).kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var leadersCountLabel: UILabel = {
        let label = UILabel.with(text: "7", textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var pointsContainerView: UIView = {
        let view = UIView(height: 70, backgroundColor: .appMainColor)
        view.cornerRadius = 10
        view.addSubview(walletImageView)
        walletImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        walletImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addSubview(walletCurrencyValue)
        walletCurrencyValue.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        walletCurrencyValue.autoPinEdge(.top, to: .top, of: walletImageView)
        
        view.addSubview(walletCurrencyLabel)
        walletCurrencyLabel.autoPinEdge(.leading, to: .trailing, of: walletCurrencyValue, withOffset: 2)
        walletCurrencyLabel.autoPinEdge(.bottom, to: .bottom, of: walletCurrencyValue, withOffset: -2)
        
        let equalLabel = UILabel.with(text: "=", textSize: 12, weight: .semibold, textColor: .white)
        view.addSubview(equalLabel)
        equalLabel.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        equalLabel.autoPinEdge(.top, to: .bottom, of: walletCurrencyValue, withOffset: 2)
        
        view.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(.leading, to: .trailing, of: equalLabel, withOffset: 2)
        communValueLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        
        let communLabel = UILabel.with(text: "Commun", textSize: 12, weight: .semibold, textColor: .white)
        view.addSubview(communLabel)
        communLabel.autoPinEdge(.leading, to: .trailing, of: communValueLabel, withOffset: 2)
        communLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        
        view.addSubview(walletButton)
        walletButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
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
        let label = UILabel.with(text: "1000", textSize: 20, weight: .semibold, textColor: .white)
        return label
    }()
    
    lazy var walletCurrencyLabel: UILabel = {
        let label = UILabel.with(text: "Binance", textSize: 12, weight: .semibold, textColor: .white)
        return label
    }()
    
    lazy var communValueLabel: UILabel = {
        let label = UILabel.with(text: "1", textSize: 12, weight: .semibold, textColor: .white)
        return label
    }()
    
    lazy var walletButton: UIButton = {
        let button = UIButton(height: 35, label: "get points".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .white, textColor: .appMainColor, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        return button
    }()
    
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
        membersCountLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(membersLabelDidTouch))
        membersCountLabel.addGestureRecognizer(tap)

        let dotLabel = UILabel.with(text: "•", textSize: 15, weight: .semibold, textColor: .a5a7bd)
        addSubview(dotLabel)
        dotLabel.autoPinEdge(.leading, to: .trailing, of: membersCountLabel, withOffset: 2)
        dotLabel.autoPinEdge(.bottom, to: .bottom, of: membersCountLabel, withOffset: 2)

        addSubview(leadersCountLabel)
        leadersCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel, withOffset: 2)
        leadersCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)
        leadersCountLabel.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(leadsLabelDidTouch))
        leadersCountLabel.addGestureRecognizer(tap2)

        addSubview(friendLabel)
        friendLabel.autoAlignAxis(.horizontal, toSameAxisOf: usersStackView)
        friendLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        friendLabel.autoPinEdge(.leading, to: .trailing, of: usersStackView, withOffset: 5)
        friendLabel.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(friendsLabelDidTouch))
        friendLabel.addGestureRecognizer(tap3)
        
        // "Don't use in MVP"
        /*
        addSubview(pointsContainerView)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        pointsContainerView.autoPinEdge(.top, to: .bottom, of: membersCountLabel, withOffset: 22)
        */
        
        let firstSeparator = UIView(height: 2, backgroundColor: .appLightGrayColor)
        addSubview(firstSeparator)
        firstSeparator.autoPinEdge(.top, to: .bottom, of: membersCountLabel, withOffset: 20)
        firstSeparator.autoPinEdge(toSuperviewEdge: .leading)
        firstSeparator.autoPinEdge(toSuperviewEdge: .trailing)
        
        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: firstSeparator)
//        segmentedControl.autoPinEdge(.top, to: .bottom, of: pointsContainerView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        let separator = UIView(height: 10, backgroundColor: .appLightGrayColor)
        addSubview(separator)
        
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    
        // "Don't use in MVP"
//        pointsContainerView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 19, offset: CGSize(width: 0, height: 14), opacity: 0.3)
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leaders".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
        
        // observe
        observeCommunityChange()
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        
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
        notificationButton.removeFromSuperview()
        if let trailingConstraint = nameLabel.constraints.first(where: {$0.firstAttribute == .trailing}) {
            nameLabel.removeConstraint(trailingConstraint)
        }
        
        if joined {
            addSubview(notificationButton)
            notificationButton.autoPinEdge(.trailing, to: .leading, of: joinButton, withOffset: -5)
            notificationButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: notificationButton.leadingAnchor, constant: -8)
                .isActive = true
        } else {
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -8)
                .isActive = true
        }
        
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
            .bold(Double(community.subscribersCount ?? 0).kmFormatted, font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold("members".localized().uppercaseFirst, font: .boldSystemFont(ofSize: 12), color: .a5a7bd)
        
        membersCountLabel.attributedText = aStr
        
        // leadsCount
        let aStr2 = NSMutableAttributedString()
            .bold("\(community.leadersCount ?? 0)", font: .boldSystemFont(ofSize: 15))
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
