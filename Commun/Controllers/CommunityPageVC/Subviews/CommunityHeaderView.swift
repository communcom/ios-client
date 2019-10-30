//
//  CommunityHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommunityHeaderView: ProfileHeaderView, CommunityController {
    
    // MARK: - CommunityController
    var community: ResponseAPIContentGetCommunity?
    
    // MARK: - Subviews
    lazy var notificationButton: UIButton = {
        let button = UIButton(width: 35, height: 35, backgroundColor: .f3f5fa, cornerRadius: 35/2, contentInsets: UIEdgeInsets(top: 10, left: 11, bottom: 10, right: 11))
        button.tintColor = .appMainColor
        button.setImage(UIImage(named: "profilepage-notification")!, for: .normal)
        return button
    }()
    lazy var joinButton = CommunButton.join
    
    lazy var membersCountLabel: UILabel = {
        let label = UILabel.with(text: Double(10000000).kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var leadsCountLabel: UILabel = {
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
        
        nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -8)
            .isActive = true
        joinedDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -8)
            .isActive = true
        
        addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 24)
        membersCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: usersStackView)
        
        let memberLabel = UILabel.with(text: "members".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(memberLabel)
        memberLabel.autoPinEdge(.leading, to: .trailing, of: membersCountLabel, withOffset: 4)
        memberLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)

        let dotLabel = UILabel.with(text: "•", textSize: 15, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(dotLabel)
        dotLabel.autoPinEdge(.leading, to: .trailing, of: memberLabel, withOffset: 2)
        dotLabel.autoPinEdge(.bottom, to: .bottom, of: memberLabel)

        addSubview(leadsCountLabel)
        leadsCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel, withOffset: 2)
        leadsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)

        let leadsLabel = UILabel.with(text: "leads".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(leadsLabel)
        leadsLabel.autoPinEdge(.leading, to: .trailing, of: leadsCountLabel, withOffset: 4)
        leadsLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)
        
        let friendLabel = UILabel.with(text: "friends".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .gray)
        addSubview(friendLabel)
        friendLabel.autoAlignAxis(.horizontal, toSameAxisOf: usersStackView)
        friendLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        friendLabel.autoPinEdge(.leading, to: .trailing, of: usersStackView, withOffset: 5)
        
        addSubview(pointsContainerView)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        pointsContainerView.autoPinEdge(.top, to: .bottom, of: membersCountLabel, withOffset: 22)
        
        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: pointsContainerView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        let separator = UIView(height: 10, backgroundColor: #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1))
        addSubview(separator)
        
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    
        pointsContainerView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 19, offset: CGSize(width: 0, height: 14), opacity: 0.3)
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leads".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
        
        // observe
        observerCommunityChange()
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        
        // avatar
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        
        // name
        nameLabel.text = community.name
        
        // joined date
        #warning("join date missing")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        let dateString = dateFormatter.string(from: Date.from(string: community.registration.time))
//        profilePageVC.joinedDateLabel.text = String(format: "%@ %@", "joined".localized().uppercaseFirst, dateString)
        joinedDateLabel.text = "joined".localized().uppercaseFirst + " " + ""
        
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle(joined ? "joined".localized().uppercaseFirst : "join".localized().uppercaseFirst, for: .normal)
        
        // notification button
        notificationButton.removeFromSuperview()
        if joined {
            addSubview(notificationButton)
            notificationButton.autoPinEdge(.trailing, to: .leading, of: joinButton, withOffset: -5)
            notificationButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        }
        
        // description
        descriptionLabel.text = community.description
        
        // membersCount
        membersCountLabel.text = Double(community.subscribersCount ?? 0).kmFormatted
        
        // leadsCount
        #warning("leads count missing")
        leadsCountLabel.text = "0"
        
        // friends
        if let friends = community.friends {
            usersStackView.setUp(with: friends)
        }
    }
    
    @objc func joinButtonDidTouch(_ button: UIButton) {
        toggleJoin()
    }
}
