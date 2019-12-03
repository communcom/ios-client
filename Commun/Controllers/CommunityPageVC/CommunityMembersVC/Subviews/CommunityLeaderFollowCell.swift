//
//  LeaderFollowCell.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityLeaderFollowCell: MyTableViewCell {
    var leader: ResponseAPIContentGetLeader?
    weak var delegate: LeaderCellDelegate?
    
    lazy var avatarImageView: LeaderAvatarImageView = {
        let imageView = LeaderAvatarImageView(size: 50)
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
    
    lazy var followButton: CommunButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        // name and points
        let namePointsContainerView = UIView(forAutoLayout: ())
        contentView.addSubview(namePointsContainerView)
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
        
        // followButton
        contentView.addSubview(followButton)
        followButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        followButton.autoAlignAxis(.horizontal, toSameAxisOf: namePointsContainerView)
        followButton.addTarget(self, action: #selector(followButtonDidTouch), for: .touchUpInside)
    }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username)
        avatarImageView.percent = leader.ratingPercent
        
        // username label
        userNameLabel.text = leader.username
        
        // point
        pointsCountLabel.text = "\(leader.rating)"
        percentsCountLabel.text = "\(leader.ratingPercent.rounded(numberOfDecimalPlaces: 2, rule: .up) * 100)"
        
        // voteButton
        let followed = leader.isSubscribed ?? false
        followButton.backgroundColor = followed ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        followButton.setTitleColor(followed ? .appMainColor: .white , for: .normal)
        followButton.setTitle(followed ? "following".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        followButton.isEnabled = !(leader.isBeingToggledFollow ?? false)
    }
    
    @objc func followButtonDidTouch() {
        guard let leader = leader else {return}
        followButton.animate {
            self.delegate?.buttonFollowDidTouch(leader: leader)
        }
    }
}
