//
//  SubscriptionsCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsCommunityCell: SubscriptionsItemCell, CommunityController {
    lazy var joinButton = CommunButton.join
    var community: ResponseAPIContentGetSubscriptionsCommunity?
    
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(joinButton)
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
        joinButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        joinButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        joinButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
            .isActive = true
        joinButton.leadingAnchor.constraint(greaterThanOrEqualTo: statsLabel.trailingAnchor, constant: 8)
            .isActive = true
    }
    
    override func observe() {
        super.observe()
        observerCommunityChange()
    }
    
    func setUp(with community: ResponseAPIContentGetSubscriptionsCommunity) {
        self.community = community
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        
        nameLabel.text = community.name
        #warning("stats label")
        
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle(joined ? "joined".localized().uppercaseFirst : "join".localized().uppercaseFirst, for: .normal)
    }
    
    @objc func joinButtonDidTouch() {
        toggleJoin()
    }
}
