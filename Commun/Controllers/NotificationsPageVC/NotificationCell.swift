//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import UIImageView_Letters
import SDWebImage
import RxSwift
import DateToolsSwift

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // Constraint for notificationTypeImage
    @IBOutlet weak var nTIBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nTILeadingConstraint: NSLayoutConstraint!
    
    // Methods
    func configure(with notification: ResponseAPIOnlineNotificationData) {
        // Fresh detect
        // TODO: Observe fresh changes
        if notification.unread {contentView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)}
        
        // Configure user's image
        if let user = notification.actor {
            let color = UIColor.avatarColorForUserWithId(user.id)
            if let avatarURL = user.avatarUrl {
                avatarImage.sd_setImage(with: URL(string: avatarURL)) { (_, error, _, _) in
                    self.avatarImage.setImageWith(user.id, color: color)
                }
            } else {
                avatarImage.setImageWith(user.id, color: color)
            }
        } else {
            setNoAvatar(for: notification)
        }
        
        // Configure image for notificationType
        let detail = NotificationType(rawValue: notification.eventType)!.getDetail(from: notification)
        notificationTypeImage.image = detail.icon
        
        // Set text for labels
        contentLabel.attributedText = detail.text
        
        timestampLabel.text = Date.from(string: notification.timestamp).shortTimeAgoSinceNow
    }
    
    private func setNoAvatar(for notification: ResponseAPIOnlineNotificationData) {
        nTILeadingConstraint.isActive = false
        nTIBottomConstraint.isActive = false
        var imageName = "NotificationNoAvatar"
        if let type = NotificationType(rawValue: notification.eventType) {
            if type == .reward || type == .votesReward {
                imageName = "NotificationNoAvatarOrange"
            } else {
                imageName = "NotificationNoAvatarBlue"
            }
        }
        avatarImage.image = UIImage(named: imageName)
    }
    
    override func prepareForReuse() {
        nTIBottomConstraint.isActive = true
        nTILeadingConstraint.isActive = true
        contentView.backgroundColor = UIColor.white
        avatarImage.image = UIImage(named: "NotificationNoAvatar")
        super.prepareForReuse()
    }
}
