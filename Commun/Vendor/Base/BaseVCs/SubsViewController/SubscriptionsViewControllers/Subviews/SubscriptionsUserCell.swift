//
//  SubscriptionsUserCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsUserCell: SubsItemCell, ListItemCellType {
    var profile: ResponseAPIContentGetSubscriptionsUser?
    var followButton: CommunButton {
        get {
            return actionButton
        }
        set {
            actionButton = newValue
        }
    }
    weak var delegate: ProfileCellDelegate?
    
    func setUp(with profile: ResponseAPIContentGetSubscriptionsUser) {
        self.profile = profile
        avatarImageView.setAvatar(urlString: profile.avatarUrl, namePlaceHolder: profile.username)
        nameLabel.text = profile.username

        // followButton
        let isFollowing = profile.isSubscribed ?? false
        followButton.backgroundColor = isFollowing ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        followButton.setTitleColor(isFollowing ? .appMainColor: .white , for: .normal)
        followButton.setTitle(isFollowing ? "following".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        followButton.isEnabled = !(profile.isBeingToggledFollow ?? false)
        statsLabel.text = "\(profile.subscribersCount ?? 0) " + "followers".localized().uppercaseFirst + " • " + "\(profile.postsCount ?? 0) " + "posts".localized().uppercaseFirst
        followButton.isHidden = Config.currentUser?.id == profile.userId
    }
    
    override func actionButtonDidTouch() {
        guard let profile = profile else {return}
        followButton.animate {
            self.delegate?.buttonFollowDidTouch(profile: profile)
        }
    }
}
