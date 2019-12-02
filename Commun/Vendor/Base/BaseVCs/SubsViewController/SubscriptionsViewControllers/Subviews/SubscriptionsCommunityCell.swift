//
//  SubscriptionsCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    var community: ResponseAPIContentGetSubscriptionsCommunity?
    weak var delegate: CommunityCellDelegate?
    
    func setUp(with community: ResponseAPIContentGetSubscriptionsCommunity) {
        self.community = community
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        
        nameLabel.text = community.name
        statsLabel.text = "\(Double(community.subscribersCount ?? 0).kmFormatted) " + "followers".localized().uppercaseFirst + " • " + "\(Double(community.postsCount ?? 0).kmFormatted) " + "posts".localized().uppercaseFirst

        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle((joined ? "following" : "follow").localized().uppercaseFirst, for: .normal)
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
    }
    
    override func actionButtonDidTouch() {
        guard let community = community else {return}
        self.delegate?.buttonFollowDidTouch(community: community)
    }
}
