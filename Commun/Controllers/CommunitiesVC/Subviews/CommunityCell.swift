//
//  CommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class CommunityCell: SubsItemCell, CommunityController {
    var joinButton: CommunButton {
        get {
            return actionButton
        }
        set {
            actionButton = newValue
        }
    }
    
    var community: ResponseAPIContentGetCommunity?
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        nameLabel.text = community.name
        
        statsLabel.text = "\(community.subscribersCount ?? 0) " + "followers".localized().uppercaseFirst + " • " + "\(community.postsCount ?? 0) " + "posts".localized().uppercaseFirst
        
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle(joined ? "joined".localized().uppercaseFirst : "join".localized().uppercaseFirst, for: .normal)
    }
    
    override func actionButtonDidTouch() {
        toggleJoin()
    }
}
