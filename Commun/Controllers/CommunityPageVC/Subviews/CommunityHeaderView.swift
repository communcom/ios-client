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
    var joinButton: CommunButton {
        get {followButton}
        set {followButton = newValue}
    }
    
    // MARK: - Subviews
    lazy var friendsCountLabel = UILabel.with(textSize: 12, weight: .bold, textColor: .appGrayColor)
    lazy var walletView = CMWalletView(forAutoLayout: ())
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        stackView.addArrangedSubviews([
            headerStackView,
            descriptionLabel,
            statsStackView,
            walletView
        ])
        
        stackView.setCustomSpacing(10, after: headerStackView)
        stackView.setCustomSpacing(16, after: statsStackView)
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "leaders".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "rules".localized().uppercaseFirst)
        ]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(friendsLabelDidTouch))
        usersStackView.label.isUserInteractionEnabled = true
        usersStackView.label.addGestureRecognizer(tap)
        
        statsStackView.addArrangedSubview(friendsCountLabel)
        statsStackView.setCustomSpacing(4, after: usersStackView)
        friendsCountLabel.isHidden = true
        friendsCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        friendsCountLabel.isUserInteractionEnabled = true
        friendsCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(friendsLabelDidTouch)))
    }
    
    // ResponseAPIWalletGetPrice(price: "647.654 BIKE", symbol: Optional("BIKE"), quantity: Optional("10 CMN"))
    func setUp(walletPrice: ResponseAPIWalletGetPrice) {
        walletView.setUp(walletPrice: walletPrice, communityName: community?.name ?? "")
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
        let attributedText = NSMutableAttributedString()
            .text(community.name, size: 20, weight: .bold)
            .text("\n")
            .text(Formatter.joinedText(with: community.registrationTime), size: 12, weight: .semibold, color: .appGrayColor)
        headerLabel.attributedText = attributedText

        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.setHightLight(joined, highlightedLabel: "following", unHighlightedLabel: "follow")
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
        
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
        let leadersCount: Int64 = community.leadersCount ?? 0
        let aStr = NSMutableAttributedString()
            .bold(membersCount.kmFormatted, font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("members-count", comment: ""), membersCount), font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
            .bold(statsSeparator, font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
            .bold("\(leadersCount.kmFormatted)", font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("leaders-count", comment: ""), leadersCount), font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
        
        statsLabel.attributedText = aStr

        // friends
        if let friends = community.friends, friends.count > 0 {
            let count = friends.count > 3 ? friends.count - 3 : friends.count
            friendsCountLabel.isHidden = false
            usersStackView.isHidden = false
            
            usersStackView.setUp(with: friends)
            friendsCountLabel.text = String(format: NSLocalizedString("friend-count", comment: ""), count)
        } else {
            friendsCountLabel.isHidden = true
            usersStackView.isHidden = true
        }
    }
    
    // MARK: - Actions
    override func joinButtonDidTouch() {
        toggleJoin()
    }
    
    @objc func friendsLabelDidTouch() {
        guard let community = community else {return}
        let vc = CommunityMembersVC(community: community, selectedSegmentedItem: .friends)
        parentViewController?.show(vc, sender: nil)
    }
    
    override func statsLabelDidTouch(_ gesture: UITapGestureRecognizer) {
        guard let text = statsLabel.text,
            let dotIndex = text.index(of: statsSeparator)?.utf16Offset(in: text)
        else { return }
        
        let tappedCharacterIndex = gesture.tappedCharacterIndexInLabel(statsLabel)
        
        if tappedCharacterIndex < dotIndex {
            membersLabelDidTouch()
        } else {
            leadsLabelDidTouch()
        }
    }
    
    func membersLabelDidTouch() {
        guard let community = community else {return}
        let vc = CommunityMembersVC(community: community, selectedSegmentedItem: .all)
        parentViewController?.show(vc, sender: nil)
    }
    
    func leadsLabelDidTouch() {
        if segmentedControl.selectedIndex.value == 1 {
            parentViewController?.view.shake()
        } else {
            segmentedControl.changeSelectedIndex(1)
        }
    }
}
