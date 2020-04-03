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
            avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        }
        
        nameLabel.text = isMyFeed ? "my feed".localized().uppercaseFirst : community.name
        
        if isMyFeed {
            statsLabel.isHidden = true
        } else {
            statsLabel.isHidden = false
            statsLabel.text = "\((community.subscribersCount ?? 0).kmFormatted) " + "followers".localized().uppercaseFirst + " • " + "\((community.postsCount ?? 0).kmFormatted) " + "posts".localized().uppercaseFirst
        }
        

        // joinButton
        if isMyFeed {
            joinButton.isHidden = true
        } else {
            joinButton.isHidden = false
            let joined = community.isSubscribed ?? false
            joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
            joinButton.setTitleColor(joined ? .appMainColor: .white, for: .normal)
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
