//
//  SubscriptionsItemCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

/// Reusable itemcell for subscribers/subscriptions
class SubsItemCell: MyTableViewCell {
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(textSize: 15, weight: .bold)
    lazy var statsLabel = UILabel.descriptionLabel()
    lazy var actionButton = CommunButton.default()
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .white
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
        
        contentView.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
        actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        actionButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
            .isActive = true
        actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: statsLabel.trailingAnchor, constant: 8)
            .isActive = true
    }
    
    @objc func actionButtonDidTouch() {
        
    }
}
