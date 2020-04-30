//
//  SubscriptionsCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsCommunityCell: SubsItemCell {
    var joinButton: CommunButton {
        get {
            return actionButton
        }
        set {
            actionButton = newValue
        }
    }
    var community: ResponseAPIContentGetCommunity?
    weak var delegate: CommunityCellDelegate?
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        
        let isMyFeed = community.communityId == "FEED"
        
        if isMyFeed {
            avatarImageView.setToCurrentUserAvatar()
        } else {
            avatarImageView.setAvatar(urlString: community.avatarUrl)
        }
        
        let attributedText = NSMutableAttributedString()
            .text(isMyFeed ? "my feed".localized().uppercaseFirst : community.name, size: 15, weight: .semibold)
        
        if !isMyFeed {
            let subscribersCount: Int64 = community.subscribersCount ?? 0
            let postsCount: Int64 = community.postsCount ?? 0
            attributedText
                .text("\n")
                .text("\(subscribersCount.kmFormatted) " +
                String(format: NSLocalizedString("followers-count", comment: ""), subscribersCount) + " • " + "\(postsCount.kmFormatted) " + String(format: NSLocalizedString("post-count", comment: "")), size: 12, weight: .semibold, color: .appGrayColor)
                .withParagraphStyle(lineSpacing: 3)
        }
        
        contentLabel.attributedText = attributedText
        
        // joinButton
        if isMyFeed {
            joinButton.isHidden = true
        } else {
            joinButton.isHidden = false
            let joined = community.isSubscribed ?? false
            joinButton.backgroundColor = joined ? .appLightGrayColor : .appMainColor
            joinButton.setTitleColor(joined ? .appMainColor: .appWhiteColor, for: .normal)
            joinButton.setTitle((joined ? "following" : "follow").localized().uppercaseFirst, for: .normal)
            joinButton.isEnabled = !(community.isBeingJoined ?? false)
        }
    }
    
    override func actionButtonDidTouch() {
        guard let community = community else {return}
        joinButton.animate {
            self.delegate?.buttonFollowDidTouch(community: community)
        }
    }
}
