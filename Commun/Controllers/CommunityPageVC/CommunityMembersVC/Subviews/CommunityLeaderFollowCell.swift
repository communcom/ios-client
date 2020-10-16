//
//  LeaderFollowCell.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CommunityLeaderFollowCell: MyTableViewCell {
    // MARK: - Properties
    var leader: ResponseAPIContentGetLeader?
    weak var delegate: LeaderCellDelegate?
    
    // MARK: - Subviews
    lazy var avatarImageView = LeaderAvatarImageView(size: 50)
    lazy var contentLabel = UILabel.with(numberOfLines: 0)
    lazy var followButton: CommunButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .appWhiteColor
        
        let stackView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            
            // name, statsLabel
            hStack.addArrangedSubview(self.avatarImageView)
            hStack.addArrangedSubview(contentLabel)
            hStack.addArrangedSubview(followButton)
            
            return hStack
        }()
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        followButton.addTarget(self, action: #selector(followButtonDidTouch), for: .touchUpInside)
    }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl)
        avatarImageView.percent = leader.ratingPercent
        
        // username label
        let attributedText = NSMutableAttributedString()
            .text(leader.username ?? "", size: 15, weight: .semibold)
            .text("\n")
            .text(leader.rating.kmFormatted() + " " + "points".localized().uppercaseFirst + " • ", size: 12, weight: .medium, color: .appGrayColor)
            .text("\(leader.ratingPercent.rounded(numberOfDecimalPlaces: 2, rule: .up) * 100)%", size: 12, weight: .medium, color: .appMainColor)
        
        // point
        contentLabel.attributedText = attributedText
        
        // voteButton
        let followed = leader.isSubscribed ?? false
        followButton.backgroundColor = followed ? .appLightGrayColor: .appMainColor
        followButton.setTitleColor(followed ? .appMainColor: .appWhiteColor, for: .normal)
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
