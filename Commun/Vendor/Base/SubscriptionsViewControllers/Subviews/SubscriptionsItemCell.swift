//
//  SubscriptionsItemCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class SubscriptionsItemCell: MyTableViewCell {
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(textSize: 15, weight: .bold)
    lazy var statsLabel = UILabel.descriptionLabel()
    
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        contentView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        nameLabel.autoPinEdge(.top, to: .top, of: avatarImageView, withOffset: 8)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentView.addSubview(statsLabel)
        statsLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        statsLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 3)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
