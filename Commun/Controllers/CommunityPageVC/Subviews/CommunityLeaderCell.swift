//
//  CommunityLeaderCell.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityLeaderCell: CommunityPageCell {
    // MARK: - Properties
    var leader: ResponseAPIContentGetLeader?
    weak var delegate: LeaderCellDelegate?
    
    // MARK: - Subviews
    lazy var avatarImageView = LeaderAvatarImageView(size: 56)
    lazy var userNameLabel = UILabel.with(text: "Sergey Marchenko", textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var pointsCountLabel = UILabel.with(text: "12,2k", textSize: 12, weight: .semibold, textColor: .appGrayColor)
    lazy var percentsCountLabel = UILabel.with(text: "50", textSize: 12, weight: .semibold, textColor: .appMainColor)
    lazy var voteButton = CommunButton.default(label: "voted".localized().uppercaseFirst)
    lazy var descriptionLabel = UILabel.with(textSize: 14, numberOfLines: 0)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        
        // background color
        contentView.backgroundColor = .appLightGrayColor
        
        // card
        let cardView = UIView(backgroundColor: .appWhiteColor, cornerRadius: .adaptive(width: 10.0))
        contentView.addSubview(cardView)
        cardView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0,
                                                                 left: .adaptive(width: 10.0),
                                                                 bottom: .adaptive(height: 20.0),
                                                                 right: .adaptive(width: 10.0)))
        
        let mainVerticalStackView = UIStackView(axis: .vertical, spacing: .adaptive(height: 14.0), alignment: .leading, distribution: .fill)
        
        cardView.addSubview(mainVerticalStackView)
        mainVerticalStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        let topHorizontalStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)

        let middleVerticalStackView = UIStackView(axis: .vertical, spacing: 3, alignment: .leading, distribution: .fill)
        middleVerticalStackView.setContentHuggingPriority(.required, for: .vertical)
        
        let pointsHorizontalStackView = UIStackView(axis: .horizontal, spacing: 4, alignment: .leading, distribution: .fill)
        
        pointsHorizontalStackView.addArrangedSubviews([ pointsCountLabel, percentsCountLabel, percentsCountLabel ])
        middleVerticalStackView.addArrangedSubviews([ userNameLabel, pointsHorizontalStackView ])
        
        topHorizontalStackView.addArrangedSubviews([ avatarImageView, middleVerticalStackView, voteButton ])
        mainVerticalStackView.addArrangedSubviews([ topHorizontalStackView, descriptionLabel ])
        topHorizontalStackView.autoPinEdge(.trailing, to: .trailing, of: mainVerticalStackView, withOffset: 0.0)
   }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl)
        avatarImageView.percent = leader.ratingPercent
        
        // username label
        userNameLabel.text = leader.username
        
        // point
        let rating = leader.rating / 1000
        pointsCountLabel.text = (rating > 1 ? String(format: "%.1fk ", rating) : String(format: "%.0f ", leader.rating)).replacingOccurrences(of: ".", with: ",") + "points".localized() + " •"
        percentsCountLabel.text = String(format: "%.0f%%", leader.ratingPercent * 100)
        
        // description
        descriptionLabel.text = leader.url
        descriptionLabel.isHidden = leader.url.isEmpty

        // voteButton
        let voted = leader.isVoted ?? false
        voteButton.backgroundColor = voted ? .appLightGrayColor : .appMainColor
        voteButton.setTitleColor(voted ? .appMainColor: .appWhiteColor, for: .normal)
        voteButton.setTitle(voted ? "voted".localized().uppercaseFirst : "vote".localized().uppercaseFirst, for: .normal)
        voteButton.isEnabled = !(leader.isBeingVoted ?? false)
        voteButton.addTarget(self, action: #selector(voteButtonDidTouch), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped))
        userNameLabel.addGestureRecognizer(tap)
        userNameLabel.isUserInteractionEnabled = true

        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(userNameTapped))
        avatarImageView.addGestureRecognizer(tapAvatar)
        avatarImageView.isUserInteractionEnabled = true
    }

    // MARK: - Actions
    @objc func voteButtonDidTouch() {
        guard let leader = leader else {return}
        voteButton.animate {
            self.delegate?.buttonVoteDidTouch(leader: leader)
        }
    }

    @objc func userNameTapped() {
        guard let leader = leader else {return}
        parentViewController?.showProfileWithUserId(leader.userId)
    }
}
