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
    lazy var label = UILabel.with(numberOfLines: 0)
    lazy var voteButton = CommunButton.default(label: "voted".localized().uppercaseFirst)
    lazy var descriptionLabel = UILabel.with(textSize: 14, numberOfLines: 0)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        
        // background color
        contentView.backgroundColor = .appLightGrayColor
        
        // card
        let cardView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        contentView.addSubview(cardView)
        cardView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0, left: 10, bottom: 20, right: 10))
        
        let vStack = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
        cardView.addSubview(vStack)
        vStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        hStack.addArrangedSubviews([avatarImageView, label, voteButton])
        label.setContentHuggingPriority(.required, for: .vertical)
        hStack.setContentHuggingPriority(.required, for: .vertical)
        
        vStack.addArrangedSubviews([hStack, descriptionLabel])
   }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl)
        avatarImageView.percent = leader.ratingPercent
        
        // label
        let rating = leader.rating / 1000
        
        label.attributedText = NSMutableAttributedString()
            .text(leader.username, size: 15, weight: .semibold)
            .text("\n")
            .text((rating > 1 ? String(format: "%.1fk ", rating) : String(format: "%.0f ", leader.rating)).replacingOccurrences(of: ".", with: ",") + "points".localized() + " • ", size: 12, weight: .semibold, color: .appGrayColor)
            .text(String(format: "%.0f%%", leader.ratingPercent * 100), size: 12, weight: .semibold, color: .appMainColor)
            .withParagraphStyle(lineSpacing: 3)
        
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
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true

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
