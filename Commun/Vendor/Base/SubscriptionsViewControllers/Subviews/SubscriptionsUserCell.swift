//
//  SubscriptionsUserCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsUserCell: SubscriptionsItemCell, ProfileController {
    var profile: ResponseAPIContentGetSubscriptionsUser?
    lazy var followButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(followButton)
        followButton.addTarget(self, action: #selector(followButtonDidTouch), for: .touchUpInside)
        followButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        followButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        followButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
            .isActive = true
        followButton.leadingAnchor.constraint(greaterThanOrEqualTo: statsLabel.trailingAnchor, constant: 8)
            .isActive = true
    }
    
    override func observe() {
        super.observe()
        observeProfileChange()
    }
    
    func setUp(with profile: ResponseAPIContentGetSubscriptionsUser) {
        self.profile = profile
        avatarImageView.setAvatar(urlString: profile.avatarUrl, namePlaceHolder: profile.username)
        nameLabel.text = profile.username
        // followButton
        let isFollowing = profile.isSubscribed ?? false
        followButton.backgroundColor = isFollowing ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        followButton.setTitleColor(isFollowing ? .appMainColor: .white , for: .normal)
        followButton.setTitle(isFollowing ? "following".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        #warning("statsLabel")
    }
    
    @objc func followButtonDidTouch() {
        toggleFollow()
    }
}
