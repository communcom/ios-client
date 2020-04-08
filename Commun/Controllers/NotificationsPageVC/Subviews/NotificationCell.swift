//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

protocol NotificationCellDelegate: class {}

class NotificationCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: NotificationCellDelegate?
    var item: ResponseAPIGetNotificationItem?
    var contentTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var isNewMark = UIView(width: 6, height: 6, backgroundColor: .appMainColor, cornerRadius: 3)
    lazy var avatarImageView = MyAvatarImageView(size: 44)
    lazy var iconImageView: UIImageView = UIImageView(width: 22, height: 22, cornerRadius: 11)
    lazy var contentContainerView = UIView(forAutoLayout: ())
    lazy var contentLabel = UILabel.with(text: "notification".localized().uppercaseFirst, textSize: 15, numberOfLines: 4)
    lazy var timestampLabel = UILabel.with(text: "ago".localized(), textSize: 13, textColor: .a5a7bd)
    
    lazy var descriptionImageView: UIImageView = {
        let imageView = UIImageView(width: 44, height: 44, cornerRadius: 10)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .appGrayColor
        return imageView
    }()
    
    lazy var actionButton = CommunButton.default(label: "follow")
    
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        contentView.addSubview(isNewMark)
        isNewMark.autoPinTopAndLeadingToSuperView(inset: 13)
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinTopAndLeadingToSuperView(inset: 16)
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: avatarImageView.bottomAnchor, constant: 16)
            .isActive = true
        
        iconImageView.contentMode = .scaleAspectFill
        contentView.addSubview(iconImageView)
        iconImageView.autoPinEdge(.trailing, to: .trailing, of: avatarImageView, withOffset: 4)
        iconImageView.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: 4)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: contentContainerView.bottomAnchor, constant: 16)
            .isActive = true
        
        contentContainerView.addSubview(contentLabel)
        contentLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        contentLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentContainerView.addSubview(timestampLabel)
        timestampLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        timestampLabel.autoPinEdge(.top, to: .bottom, of: contentLabel, withOffset: 2)
        timestampLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // pin trailing of content
        contentTrailingConstraint = contentContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        selectionStyle = .none
    }
    
    // MARk: - Methods
    func setUp(with item: ResponseAPIGetNotificationItem) {
        self.item = item
        
        // clear
        actionButton.removeFromSuperview()
        descriptionImageView.removeFromSuperview()
        contentTrailingConstraint?.isActive = false
        contentTrailingConstraint = contentContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // common setup
        isNewMark.isHidden = !item.isNew
        
        iconImageView.isHidden = false
        iconImageView.borderColor = .clear
        iconImageView.borderWidth = 0
        
        let dateString = Date.from(string: item.timestamp).string(withFormat: "HH:mm")
        timestampLabel.text = dateString
        
        var avatarUrl = (item.author ?? item.voter ?? item.user)?.avatarUrl
        var userId = (item.author ?? item.voter ?? item.user)?.userId
        var avatarPlaceholder = (item.author ?? item.voter ?? item.user)?.username ?? "User"
        
        // content
        contentLabel.attributedText = item.attributedContent
        
        switch item.eventType {
        case "mention":
            iconImageView.image = UIImage(named: "notifications-page-mention")
            
        case "subscribe":
            iconImageView.isHidden = true
            // TODO: - follow ?? unfollow
//            contentView.addSubview(actionButton)
//            actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
//            actionButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
//            actionButton.setTitle("follow", for: .normal)
//            
//            contentTrailingConstraint?.isActive = false
//            contentTrailingConstraint = contentContainerView.autoPinEdge(.trailing, to: .leading, of: actionButton, withOffset: -4)

        case "upvote":
            iconImageView.image = UIImage(named: "notifications-page-upvote")
            
            if let imageUrl = item.comment?.imageUrl ?? item.post?.imageUrl {
                contentView.addSubview(descriptionImageView)
                descriptionImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
                descriptionImageView.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
                
                descriptionImageView.setImageDetectGif(with: imageUrl, customWidth: UIScreen.main.bounds.width)
                
                contentTrailingConstraint?.isActive = false
                contentTrailingConstraint = contentContainerView.autoPinEdge(.trailing, to: .leading, of: descriptionImageView, withOffset: -4)
            }
            
        case "reply":
            iconImageView.image = UIImage(named: "notifications-page-reply")
        case "reward":
            avatarUrl = item.community?.avatarUrl
            avatarPlaceholder = item.community?.name ?? "Community"
        case "transfer":
            avatarUrl = item.from?.avatarUrl
            avatarPlaceholder = item.from?.username ?? "User"
            if item.from?.username == nil {
                iconImageView.isHidden = true
                avatarUrl = "https://commun.com/apple-touch-icon.png"
                userId = nil
            } else if item.from?.username?.lowercased() != "bounty" {
                iconImageView.isHidden = true
            } else {
                iconImageView.setAvatar(urlString: item.community?.avatarUrl, namePlaceHolder: item.community?.name ?? "C")
                iconImageView.borderWidth = 2
                iconImageView.borderColor = .white
            }
        case "referralRegistrationBonus", "referralPurchaseBonus":
            avatarUrl = item.from?.avatarUrl
        default:
            iconImageView.isHidden = true
        }

        if let userId = userId {
            avatarImageView.addTapToOpenUserProfile(profileId: userId)
        }

        avatarImageView.setAvatar(urlString: avatarUrl, namePlaceHolder: avatarPlaceholder)
    }
}
