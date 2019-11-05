//
//  CommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class SubscriptionCommunityCell: MyCollectionViewCell, CommunityController {
    // MARK: - Properties
    var community: ResponseAPIContentGetSubscriptionsCommunity?
    
    // MARK: - Subviews
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.image = .placeholder
        return imageView
    }()
    lazy var avatarImageView: MyAvatarImageView = {
        let avatar = MyAvatarImageView(size: 50)
        avatar.borderWidth = 2
        avatar.borderColor = .white
        return avatar
    }()
    
    lazy var nameLabel = UILabel.with(text: "Behance", textSize: 15, weight: .semibold, textAlignment: .center)
    lazy var membersCountLabel = UILabel.with(text: "12,2k members", textSize: 12, weight: .semibold, textColor: .a5a7bd, textAlignment: .center)
    lazy var joinButton = CommunButton.join
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 46, left: 5, bottom: 16, right: 5))
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 34)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        containerView.addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 5)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        containerView.addSubview(joinButton)
        joinButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .top)
        
        containerView.addShadow(ofColor: UIColor(red: 176, green: 176, blue: 204)!, radius: 25, offset: CGSize(width: 0, height: 10), opacity: 0.25)
        
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
    }
    
    func setUp(with community: ResponseAPIContentGetSubscriptionsCommunity) {
        self.community = community
        self.avatarImageView.setAvatarDetectGif(with: community.avatarUrl, placeholderName: community.name)
        self.coverImageView.setImageDetectGif(with: community.coverUrl)
        
        nameLabel.text = community.name
        
        #warning("subscribersCount missing")
        
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle(joined ? "joined".localized().uppercaseFirst : "join".localized().uppercaseFirst, for: .normal)
    }
    
    @objc func joinButtonDidTouch() {
        toggleJoin()
    }
}
