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
        followButton.autoPinEdge(.leading, to: .trailing, of: nameLabel, withOffset: 10)
        followButton.autoPinEdge(.leading, to: .trailing, of: statsLabel, withOffset: 10)
    }
    
    override func observe() {
        super.observe()
        observeProfileChange()
    }
    
    func setUp(with profile: ResponseAPIContentGetSubscriptionsUser) {
        self.profile = profile
        avatarImageView.setAvatar(urlString: profile.avatarUrl, namePlaceHolder: profile.username)
        nameLabel.text = profile.username
    }
    
    @objc func followButtonDidTouch() {
        toggleFollow()
    }
}
