//
//  WalletAddFriendCell.swift
//  Commun
//
//  Created by Chung Tran on 2/21/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol WalletAddFriendCellDelegate: ProfileCellDelegate {
    func sendPointButtonDidTouch(friend: ResponseAPIContentGetProfile)
}

class WalletAddFriendCell: SubscriptionsUserCell {
    weak private var _delegate: WalletAddFriendCellDelegate?
    override weak var delegate: ProfileCellDelegate? {
        didSet {
            _delegate = delegate as? WalletAddFriendCellDelegate
        }
    }
    
    override func setUpFollowButton(with profile: ResponseAPIContentGetProfile) {
        let isFollowing = profile.isSubscribed ?? false
        followButton.setTitle(isFollowing ? "send points".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        followButton.isEnabled = !(profile.isBeingToggledFollow ?? false)
        followButton.isHidden = Config.currentUser?.id == profile.userId
    }
    
    override func actionButtonDidTouch() {
        guard let profile = profile else {return}
        followButton.animate {
            if profile.isSubscribed == true {
                self._delegate?.sendPointButtonDidTouch(friend: profile)
            } else {
                self.delegate?.buttonFollowDidTouch(profile: profile)
            }
        }
    }
}
