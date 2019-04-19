//
//  ProfilePageVC+Profile.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: ProfilePageVC {
    /// Bind profile to view.
    var profile: Binder<ResponseAPIContentGetProfile> {
        return Binder(self.base) { profilePageVC, profile in
            // profile image
            if let avatarUrl = profile.personal.avatarUrl {
                profilePageVC.userAvatarImage.sd_setImage(with: URL(string: avatarUrl)) { (_, error, _, _) in
                    if (error != nil) {
                        // Placeholder image
                        profilePageVC.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
                    }
                }
            } else {
                // Placeholder image
                profilePageVC.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
            }
            
            // user name
            profilePageVC.userNameLabel.text = profile.username
            
            // join date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
            profilePageVC.joinedDateLabel.text = ("Joined".localized() + " " + dateString)
            
            // count labels
            profilePageVC.followingsCountLabel.text = "\(profile.subscriptions.userIds.count)"
            profilePageVC.communitiesCountLabel.text = "\(profile.subscriptions.communities.count)"
            #warning("missing followers count")
        }
    }
    
}


