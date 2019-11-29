//
//  CommunityLeaderCell.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityLeaderCell: CommunityPageCell, LeaderController {
    var leader: ResponseAPIContentGetLeader?
    
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
    
    lazy var voteButton: CommunButton = CommunButton.default(label: "vote".localized().uppercaseFirst)
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(textSize: 14, numberOfLines: 0)
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
        avatarImageView.autoPinTopAndLeadingToSuperView(inset: 16)
        
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
        voteButton.addTarget(self, action: #selector(voteButtonDidTouch), for: .touchUpInside)
        
        // descriptionLabel
        cardView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 16)
        descriptionLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
    }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username ?? leader.userId)
        avatarImageView.percent = leader.ratingPercent
        
        // username label
        userNameLabel.text = leader.username
        
        // point
        pointsCountLabel.text = "\(leader.rating)"
        percentsCountLabel.text = "\(leader.ratingPercent.rounded(numberOfDecimalPlaces: 2, rule: .up) * 100)"
        
        #warning("description missing")
        
        // voteButton
        let voted = leader.votesCount > 0
        voteButton.backgroundColor = voted ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        voteButton.setTitleColor(voted ? .appMainColor: .white , for: .normal)
        voteButton.setTitle(voted ? "voted".localized().uppercaseFirst : "vote".localized().uppercaseFirst, for: .normal)
        voteButton.isEnabled = !(leader.isBeingVoted ?? false)
    }
    
    @objc func voteButtonDidTouch() {
        toggleVote()
    }
}
