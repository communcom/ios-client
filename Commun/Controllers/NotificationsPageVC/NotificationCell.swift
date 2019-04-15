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

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    // Constraint for notificationTypeImage
    @IBOutlet weak var nTIBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nTILeadingConstraint: NSLayoutConstraint!
    
    // Methods
    func configure(with notification: ResponseAPIOnlineNotificationData) {
        // Fresh detect
        // TODO: Observe fresh changes
        if notification.fresh {contentView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)}
        
        // Configure user's image
        if let user = notification.actor {
            if let avatarURL = user.avatarUrl {
                avatarImage.sd_setImage(with: URL(string: avatarURL)) { (_, error, _, _) in
                    self.avatarImage.setImageWith(user.id, color: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1))
                }
            } else {
                avatarImage.setImageWith(user.id, color: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1))
            }
        } else {
            setNoAvatar()
        }
        
        // Configure image for notificationType
        let detail = NotificationType(rawValue: notification.eventType)!.getDetail(from: notification)
        notificationTypeImage.image = detail.icon
        
        // Set text for labels
        contentLabel.attributedText = detail.text
        
        
        
        
    }
    
    private func setNoAvatar() {
        nTILeadingConstraint.isActive = false
        nTIBottomConstraint.isActive = false
        avatarImage.image = UIImage(named: "NotificationNoAvatar")
    }
    
    override func prepareForReuse() {
        nTIBottomConstraint.isActive = true
        nTILeadingConstraint.isActive = true
        contentView.backgroundColor = UIColor.white
        super.prepareForReuse()
    }
}
