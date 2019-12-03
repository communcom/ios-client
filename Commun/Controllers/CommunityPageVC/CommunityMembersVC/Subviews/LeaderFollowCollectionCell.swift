//
//  LeaderFollowCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class LeaderFollowCollectionCell: LeaderCollectionCell {
    var followButton: CommunButton {
        return voteButton
    }
    
    override func setUp(with item: ResponseAPIContentGetLeader) {
        super.setUp(with: item)
        // followButton
        let followed = leader?.isSubscribed ?? false
        followButton.setHightLight(followed, highlightedLabel: "following", unHighlightedLabel: "follow")
        followButton.isEnabled = !(leader?.isBeingToggledFollow ?? false)
    }
    
    override func voteButtonDidTouch() {
        guard let leader = leader else {return}
        followButton.animate {
            self.delegate?.buttonFollowDidTouch(leader: leader)
        }
    }
}
