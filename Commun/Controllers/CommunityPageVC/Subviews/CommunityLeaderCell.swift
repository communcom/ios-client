//
//  CommunityLeaderCell.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityLeaderCell: CommunityPageCell {
    lazy var avatarImageView: LeaderAvatarImageView = {
        let imageView = LeaderAvatarImageView(size: 56)
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel.with(text: "Sergey Marchenko", textSize: 15, weight: .semibold)
        return label
    }()
    
    lazy var pointsCountLabel: UILabel = {
        let label = UILabel.with(text: "12,2k", textSize: 12, weight: .semibold, textColor: .a5a7bd)
        return label
    }()
    
    lazy var percentsCountLabel: UILabel = {
        let label = UILabel.with(text: "50", textSize: 12, weight: .semibold, textColor: .appMainColor)
        return label
    }()
    
    lazy var voteButton: CommunButton = {
        let button = CommunButton(height: 35, label: "vote".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return button
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(text: "Tell how you would influence the community and make it better becomi... Read", textSize: 14, numberOfLines: 0)
        return label
    }()
    
    override func setUpViews() {
        super.setUpViews()
        // background color
        contentView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        
        // card
        let cardView = UIView(backgroundColor: .white, cornerRadius: 10)
        contentView.addSubview(cardView)
        cardView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        
        // layout card
        cardView.addSubview(avatarImageView)
        avatarImageView.autoPinTopAndLeadingToSuperView()
        
        // name and points
        let namePointsContainerView = UIView(forAutoLayout: ())
        cardView.addSubview(namePointsContainerView)
        namePointsContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        namePointsContainerView.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        
        namePointsContainerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        namePointsContainerView.addSubview(pointsCountLabel)
        pointsCountLabel.autoPinBottomAndLeadingToSuperView(inset: 0)
        pointsCountLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel)
        
        let pointsLabel = UILabel.with(text: "points".localized().uppercaseFirst + " • ", textSize: 12, weight: .semibold, textColor: .a5a7bd)
        namePointsContainerView.addSubview(pointsLabel)
        pointsLabel.autoPinEdge(.leading, to: .trailing, of: pointsCountLabel, withOffset: 5)
        pointsLabel.autoPinEdge(.bottom, to: .bottom, of: pointsCountLabel)
        
        namePointsContainerView.addSubview(percentsCountLabel)
        percentsCountLabel.autoPinEdge(.leading, to: .trailing, of: pointsLabel)
        percentsCountLabel.autoPinEdge(.bottom, to: .bottom, of: pointsCountLabel)
        
        let percentLabel = UILabel.with(text: "%", textSize: 12, weight: .semibold, textColor: .appMainColor)
        namePointsContainerView.addSubview(percentLabel)
        percentLabel.autoPinEdge(.leading, to: .trailing, of: percentsCountLabel)
        percentLabel.autoPinEdge(.bottom, to: .bottom, of: pointsCountLabel)
        
        // vote button
        cardView.addSubview(voteButton)
        voteButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        voteButton.autoAlignAxis(.horizontal, toSameAxisOf: namePointsContainerView)
        
        // descriptionLabel
        cardView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 16)
        descriptionLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
    }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username ?? leader.userId)
        userNameLabel.text = leader.username
        avatarImageView.percent = leader.ratingPercent
    }
}
