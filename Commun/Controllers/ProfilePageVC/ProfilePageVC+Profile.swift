//
//  ProfilePageVC+Profile.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ProfilePageVC {
    func showProfile(_ profile: ResponseAPIContentGetProfile) {
        self.activityIndicator.stopAnimating()
        self.tableView.isHidden = false
        
        // profile image
        if let avatarUrl = profile.personal.avatarUrl {
            userAvatarImage.sd_setImage(with: URL(string: avatarUrl)) { (_, error, _, _) in
                if (error != nil) {
                    // TODO: Placeholder image
                    self.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
                }
            }
        } else {
            // TODO: Placeholder image
            self.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
        }
        
        // user name
        userNameLabel.text = profile.username
        
        // join date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
        joinedDateLabel.text = ("Joined".localized() + " " + dateString)
        
        // count labels
        followingsCountLabel.text = "\(profile.subscriptions.userIds.count)"
        communitiesCountLabel.text = "\(profile.subscriptions.communities.count)"
        #warning("missing followers count")
        
    }
}
