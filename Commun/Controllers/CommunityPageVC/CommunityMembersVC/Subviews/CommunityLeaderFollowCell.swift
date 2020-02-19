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
    lazy var userNameLabel = UILabel.with(text: "Sergey Marchenko", textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var statsLabel = UILabel.with(text: "601k Points • 42.0%", textSize: 12, weight: .medium, numberOfLines: 0)
    lazy var followButton: CommunButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        
        let stackView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            
            // name, statsLabel
            let vStack = UIStackView(axis: .vertical, alignment: .leading, distribution: .fill)
            vStack.addArrangedSubview(self.userNameLabel)
            vStack.addArrangedSubview(self.statsLabel)
            
            hStack.addArrangedSubview(self.avatarImageView)
            hStack.addArrangedSubview(vStack)
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
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username)
        avatarImageView.percent = leader.ratingPercent
        
        // username label
        userNameLabel.text = leader.username
        
        // point
        statsLabel.attributedText = NSMutableAttributedString()
            .text(leader.rating.kmFormatted() + " " + "points".localized().uppercaseFirst + " • ", size: 12, weight: .medium, color: .a5a7bd)
            .text("\(leader.ratingPercent.rounded(numberOfDecimalPlaces: 2, rule: .up) * 100)%", size: 12, weight: .medium, color: .appMainColor)
        
        // voteButton
        let followed = leader.isSubscribed ?? false
        followButton.backgroundColor = followed ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        followButton.setTitleColor(followed ? .appMainColor: .white, for: .normal)
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
