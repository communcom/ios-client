//
//  SubscriptionsUserCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsUserCell: SubsItemCell, ListItemCellType {
    var profile: ResponseAPIContentGetProfile?
    var followButton: CommunButton {
        get {
            return actionButton
        }
        set {
            actionButton = newValue
        }
    }
    weak var delegate: ProfileCellDelegate?
    
    func setUp(with profile: ResponseAPIContentGetProfile) {
        self.profile = profile
        avatarImageView.setAvatar(urlString: profile.avatarUrl)
        let attributedText = NSMutableAttributedString()
            .text(profile.username ?? "", size: 15, weight: .semibold)
            .text("\n")
            .text(String(format: NSLocalizedString("%d followers", comment: ""), (profile.subscribersCount ?? 0)) + " • " + String(format: NSLocalizedString("%d posts", comment: ""), (profile.postsCount ?? 0)), size: 12, weight: .semibold, color: .appGrayColor)
            .withParagraphStyle(lineSpacing: 3)
        contentLabel.attributedText = attributedText

        // followButton
        setUpFollowButton(with: profile)
    }
    
    func setUpFollowButton(with profile: ResponseAPIContentGetProfile) {
        let isFollowing = profile.isSubscribed ?? false
        followButton.backgroundColor = isFollowing ? .appLightGrayColor : .appMainColor
        followButton.setTitleColor(isFollowing ? .appMainColor: .appWhiteColor, for: .normal)
        followButton.setTitle(isFollowing ? "following".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        followButton.isEnabled = !(profile.isBeingToggledFollow ?? false)
        
        followButton.isHidden = Config.currentUser?.id == profile.userId
    }
    
    override func actionButtonDidTouch() {
        guard let profile = profile else {return}
        followButton.animate {
            self.delegate?.buttonFollowDidTouch(profile: profile)
        }
    }
}
