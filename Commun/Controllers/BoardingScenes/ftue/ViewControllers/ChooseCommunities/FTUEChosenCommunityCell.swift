//
//  FTUEChosenCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class FTUEChosenCommunityCell: MyCollectionViewCell {
    lazy var avatarImageView = LeaderAvatarImageView(size: 50)
    lazy var deleteButton: UIButton = {
        let button = UIButton.close()
        button.borderWidth = 2
        button.borderColor = .appWhiteColor
        return button
    }()
    
    var community: ResponseAPIContentGetCommunity?
    weak var delegate: CommunityCellDelegate?
    
    override func setUpViews() {
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges()
        
        contentView.addSubview(deleteButton)
        deleteButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        deleteButton.autoPinEdge(.top, to: .top, of: avatarImageView)
        
        deleteButton.addTarget(self, action: #selector(buttonDeleteDidTouch), for: .touchUpInside)
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        avatarImageView.setAvatar(urlString: community.avatarUrl)
        avatarImageView.percent = 1
        
        if community.isBeingJoined == true {
            avatarImageView.alpha = 0.6
            deleteButton.isEnabled = false
        } else {
            avatarImageView.alpha = 1
            deleteButton.isEnabled = true
        }
    }
    
    @objc func buttonDeleteDidTouch() {
        guard let community = community else {return}
        delegate?.forceFollow(false, community: community)
    }
}
