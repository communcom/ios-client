//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommentCell: MyTableViewCell {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentContainerView = UIView(backgroundColor: .f3f5fa, cornerRadius: 12)
    lazy var contentLabel = UILabel.with(text: "Andrey Ivanov Welcome! 😄 Wow would love to wake", textSize: 15, numberOfLines: 0)
    lazy var embedView = UIView(width: 192, height: 101)
    lazy var voteContainerView: VoteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        contentContainerView.addSubview(contentLabel)
        contentLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)
        
        contentContainerView.addSubview(embedView)
        embedView.autoPinEdge(.leading, to: .leading, of: contentLabel)
        embedView.autoPinEdge(.top, to: .bottom, of: contentLabel)
        
        embedView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
}
