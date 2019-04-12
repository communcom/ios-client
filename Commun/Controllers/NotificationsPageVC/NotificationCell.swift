//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import IPImage
import SDWebImage

class NotificationCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    
    // Constraint for notificationTypeImage
    @IBOutlet weak var nTIBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nTILeadingConstraint: NSLayoutConstraint!
    
    // Methods
    func configure(with notification: ResponseAPIOnlineNotification) {
        // Configure image
        if let user = notification.actor {
            let ipImage = IPImage(text: user.id, radius: 0).generateImage()
            if let avatarURL = user.avatarUrl {
                avatarImage.sd_setImage(with: URL(string: avatarURL), placeholderImage: ipImage)
            } else {
                avatarImage.image = ipImage
            }
        } else {
            setNoAvatar()
        }
    }
    
    private func setNoAvatar() {
        nTILeadingConstraint.isActive = false
        nTIBottomConstraint.isActive = false
    }
    
    override func prepareForReuse() {
        nTIBottomConstraint.isActive = true
        nTILeadingConstraint.isActive = true
        super.prepareForReuse()
    }
}
