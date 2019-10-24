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

class CommunityHeaderView: MyTableHeaderView {
    // MARK: - Subviews
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(width: 50, height: 50)
        imageView.cornerRadius = 25
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.with(text: "Community", textSize: 20, weight: .bold)
        return label
    }()
    
    lazy var joinedDateLabel: UILabel = {
        let label = UILabel.descriptionLabel("Joined", size: 12)
        return label
    }()
    
    lazy var joinButton: UIButton = {
        let button = UIButton(height: 35, label: "join".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return button
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(text: "Binance Exchange provides cryptocurrency trading for fintech and blockchain enthusiasts", textSize: 14, numberOfLines: 0)
        return label
    }()
    
    lazy var membersCountLabel: UILabel = {
        let label = UILabel.with(text: Double(10000000).kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var leadsCountLabel: UILabel = {
        let label = UILabel.with(text: "7", textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var usersStackView: UsersStackView = {
        let stackView = UsersStackView(height: 34)
        return stackView
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
    
    lazy var segmentedControl: CMSegmentedControl = {
        let segmentedControl = CMSegmentedControl(height: 46, backgroundColor: .clear)
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leads".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
        return segmentedControl
    }()
    
    // MARK: - Properties
    var selectedIndex: BehaviorRelay<Int> {
        return segmentedControl.selectedIndex
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        addSubview(joinedDateLabel)
        joinedDateLabel.autoPinEdge(.top, to: .bottom, of: nameLabel)
        joinedDateLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        addSubview(joinButton)
        joinButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        joinButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        
        addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 10)
        
        addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 24)
        
        let memberLabel = UILabel.with(text: "members".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(memberLabel)
        memberLabel.autoPinEdge(.leading, to: .trailing, of: membersCountLabel, withOffset: 4)
        memberLabel.autoPinEdge(.bottom, to: .bottom, of: membersCountLabel, withOffset: -1)

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
        leadsLabel.autoPinEdge(.bottom, to: .bottom, of: leadsCountLabel, withOffset: -1)
        
        addSubview(usersStackView)
        usersStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        usersStackView.autoAlignAxis(.horizontal, toSameAxisOf: leadsLabel)
        
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
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        // avatar
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name ?? community.communityId ?? "C")
        
        // name
        nameLabel.text = community.name ?? community.communityId
        
        // joined date
        #warning("join date missing")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        let dateString = dateFormatter.string(from: Date.from(string: community.registration.time))
//        profilePageVC.joinedDateLabel.text = String(format: "%@ %@", "joined".localized().uppercaseFirst, dateString)
        joinedDateLabel.text = "joined".localized().uppercaseFirst + " " + ""
        
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
}
