//
//  CommunityCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CommunityCollectionCell: MyCollectionViewCell, ListItemCellType {
    // MARK: - Properties
    var community: ResponseAPIContentGetCommunity?
    weak var delegate: CommunityCellDelegate?
    var shouldAnimateOnFollowing = true
    
    // MARK: - Subviews
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var avatarImageView: MyAvatarImageView = {
        let avatar = MyAvatarImageView(size: 50)
        avatar.backgroundColor = .appWhiteColor
        avatar.borderWidth = 2
        avatar.borderColor = .appWhiteColor
        return avatar
    }()
    
    lazy var nameLabel = UILabel.with(text: "Behance", textSize: 15, weight: .semibold, textAlignment: .center)
    lazy var descriptionLabel = UILabel.with(text: "12,2k members", textSize: 12, weight: .semibold, textColor: .appGrayColor, numberOfLines: 0, textAlignment: .center)
    lazy var joinButton = CommunButton.default(height: 30, label: "follow".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()

        contentView.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let containerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)

        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 46, left: 5, bottom: 16, right: 5))
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 34)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 3)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

        containerView.addSubview(joinButton)
        joinButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .top)

        containerView.addShadow(ofColor: UIColor.colorSupportDarkMode(defaultColor: UIColor(red: 176, green: 176, blue: 204)!, darkColor: .black), radius: 25, offset: CGSize(width: 0, height: 10), opacity: 0.25)

        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
    }
    
    // MARK: - Methods
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        self.avatarImageView.setAvatarDetectGif(with: community.avatarUrl)
        self.coverImageView.setImageDetectGif(with: community.coverUrl)
        
        nameLabel.text = community.name

        let count: Int64 = community.subscribersCount ?? 0
        descriptionLabel.text = "\(count.kmFormatted) " + String(format: NSLocalizedString("members-count", comment: ""), count)
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.setHightLight(joined, highlightedLabel: "following", unHighlightedLabel: "follow")
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
    }
    
    @objc func joinButtonDidTouch() {
        guard let community = community else {return}
        if shouldAnimateOnFollowing {
            joinButton.animate {
                self.delegate?.buttonFollowDidTouch(community: community)
            }
        } else {
            self.delegate?.buttonFollowDidTouch(community: community)
        }
    }
}
