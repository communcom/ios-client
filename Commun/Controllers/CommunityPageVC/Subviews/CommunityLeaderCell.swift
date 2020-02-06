//
//  CommunityLeaderCell.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityLeaderCell: CommunityPageCell {
    var leader: ResponseAPIContentGetLeader?
    weak var delegate: LeaderCellDelegate?
    
    lazy var avatarImageView: LeaderAvatarImageView = {
        let imageView = LeaderAvatarImageView(size: 56)
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel.with(text: "Sergey Marchenko", textSize: .adaptive(width: 15.0), weight: .semibold)
        return label
    }()
    
    lazy var pointsCountLabel: UILabel = {
        let label = UILabel.with(text: "12,2k", textSize: .adaptive(width: 12.0), weight: .semibold, textColor: .a5a7bd)
        return label
    }()
    
    lazy var percentsCountLabel: UILabel = {
        let label = UILabel.with(text: "50", textSize: .adaptive(width: 12.0), weight: .semibold, textColor: .appMainColor)
        return label
    }()
    
    lazy var voteButton: CommunButton = CommunButton.default(label: "voted".localized().uppercaseFirst)
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(textSize: .adaptive(width: 14.0), numberOfLines: 0)
        return label
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        // background color
        contentView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        
        // card
        let cardView = UIView(backgroundColor: .white, cornerRadius: .adaptive(width: 10.0))
        contentView.addSubview(cardView)
        cardView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0,
                                                                 left: .adaptive(width: 10.0),
                                                                 bottom: .adaptive(height: 20.0),
                                                                 right: .adaptive(width: 10.0)))

        
        let mainVerticalStackView = UIStackView(axis: .vertical, spacing: .adaptive(height: 14.0))
        mainVerticalStackView.alignment = .leading
        mainVerticalStackView.distribution = .fillProportionally
        
        cardView.addSubview(mainVerticalStackView)
        mainVerticalStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 30.0)))
        
        let topHorizontalStackView = UIStackView(axis: .horizontal, spacing: .adaptive(width: 10.0))
        topHorizontalStackView.alignment = .center
        topHorizontalStackView.distribution = .fillProportionally

        let middleVerticalStackView = UIStackView(axis: .vertical, spacing: .adaptive(height: 5.0))
        middleVerticalStackView.alignment = .leading
        middleVerticalStackView.distribution = .fillProportionally
        middleVerticalStackView.setContentHuggingPriority(251.0, for: .horizontal)
        
        let pointsHorizontalStackView = UIStackView(axis: .horizontal, spacing: .adaptive(width: 4.0))
        pointsHorizontalStackView.alignment = .leading
        pointsHorizontalStackView.distribution = .fillProportionally
        
        pointsHorizontalStackView.addArrangedSubviews([ pointsCountLabel, percentsCountLabel, percentsCountLabel ])
        middleVerticalStackView.addArrangedSubviews([ userNameLabel, pointsHorizontalStackView ])
        
        voteButton.widthAnchor.constraint(equalToConstant: .adaptive(width: 65.0)).isActive = true
        topHorizontalStackView.addArrangedSubviews([ avatarImageView, middleVerticalStackView, voteButton ])
        mainVerticalStackView.addArrangedSubviews([ topHorizontalStackView, descriptionLabel ])
        topHorizontalStackView.autoPinEdge(.trailing, to: .trailing, of: mainVerticalStackView, withOffset: 0.0)
   }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        
        // avatar
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username)
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
        voteButton.backgroundColor = voted ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1) : .appMainColor
        voteButton.setTitleColor(voted ? .appMainColor: .white, for: .normal)
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
