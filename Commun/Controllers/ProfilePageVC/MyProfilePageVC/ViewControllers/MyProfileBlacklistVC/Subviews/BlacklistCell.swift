//
//  BlacklistUserCell.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class BlacklistCell: MyTableViewCell {
    // MARK: - Properties
    var item: ResponseAPIContentGetBlacklistItem?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var blockButton = CommunButton.default(label: "Unblock")
    
    // MARK: - Methods
    override func setUpViews() {
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        contentView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        nameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        contentView.addSubview(blockButton)
        blockButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        blockButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        blockButton.autoPinEdge(.trailing, to: .leading, of: nameLabel, withOffset: 8)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setUp(with item: ResponseAPIContentGetBlacklistItem) {
        self.item = item
        switch item {
        case .user(let user):
            avatarImageView.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username)
            nameLabel.text = user.username
        case .community(let community):
            avatarImageView.setAvatar(urlString: nil, namePlaceHolder: community.name)
            nameLabel.text = community.name
        }
    }
}
