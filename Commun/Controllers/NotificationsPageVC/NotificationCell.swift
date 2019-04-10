//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    
    // Constraint for notificationTypeImage
    @IBOutlet weak var nTIBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nTILeadingConstraint: NSLayoutConstraint!
    
    // Methods
    // func configure(with model: )
    
    func configureWithOutAvatar() {
        nTILeadingConstraint.isActive = false
        nTIBottomConstraint.isActive = false
    }
    
    override func prepareForReuse() {
        nTIBottomConstraint.isActive = true
        nTILeadingConstraint.isActive = true
        super.prepareForReuse()
    }
}
