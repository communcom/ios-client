//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import ListPlaceholder

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // Constraint for notificationTypeImage
    @IBOutlet var nTIBottomConstraint: NSLayoutConstraint!
    @IBOutlet var nTILeadingConstraint: NSLayoutConstraint!
    
    // Methods
    func configure(with notification: ResponseAPIOnlineNotificationData) {
        // For placeholder cell
        self.contentView.hideLoader()
        if notification._id.starts(with: "___mock___") {
            self.contentView.showLoader()
            return
        }
        
        // Fresh detect
        // TODO: Observe fresh changes
        if notification.unread {contentView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)}
        
        guard let type = NotificationType(rawValue: notification.eventType) else {
            avatarImage.image = UIImage(named: "NotificationAvatarPlaceholder")
            notificationTypeImage.image = UIImage(named: "NotificationMention")
            contentLabel.text = "You have a new notification".localized()
            return
        }
    
        // Configure user's image
        
        if let user = notification.actor,
            type != NotificationType.curatorReward && type != NotificationType.reward {
            avatarImage.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username ?? user.userId ?? "Unknown")
        } else {
            setNoAvatar(for: notification)
        }
        
        // Configure image for notificationType
        
        let detail = type.getDetail(from: notification)
        notificationTypeImage.image = detail.icon
        
        // Set text for labels
        contentLabel.attributedText = detail.text
        
        
        timestampLabel.text = Date.timeAgo(string: notification.timestamp)
        
        categoryLabel.text = notification.community?.name
    }
    
    private func setNoAvatar(for notification: ResponseAPIOnlineNotificationData) {
        nTILeadingConstraint.isActive = false
        nTIBottomConstraint.isActive = false
        var imageName = "NotificationNoAvatar"
        if let type = NotificationType(rawValue: notification.eventType) {
            if type == .reward || type == .curatorReward {
                imageName = "NotificationNoAvatarOrange"
            } else {
                imageName = "NotificationNoAvatarBlue"
            }
        }
        avatarImage.image = UIImage(named: imageName)
        self.notificationTypeImage.updateConstraints()
    }
    
    override func prepareForReuse() {
        nTIBottomConstraint.isActive = true
        nTILeadingConstraint.isActive = true
        contentView.backgroundColor = UIColor.white
        avatarImage.image = UIImage(named: "NotificationNoAvatar")
        super.prepareForReuse()
    }
}
