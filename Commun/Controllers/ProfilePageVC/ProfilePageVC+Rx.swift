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
            // cover image
            if let coverUrl = profile.personal.coverUrl {
                profilePageVC.userCoverImage.sd_setImage(with: URL(string: coverUrl), placeholderImage: UIImage(named: "ProfilePageCover"))
            }
            
            // profile image
            if let avatarUrl = profile.personal.avatarUrl {
                profilePageVC.userAvatarImage.sd_setImage(with: URL(string: avatarUrl)) { (_, error, _, _) in
                    if (error != nil) {
                        // Placeholder image
                        profilePageVC.userAvatarImage.setNonAvatarImageWithId(profile.username)
                    }
                }
            } else {
                // Placeholder image
                profilePageVC.userAvatarImage.setNonAvatarImageWithId(profile.username)
            }
            
            // user name
            profilePageVC.userNameLabel.text = profile.username
            
            // bio
            if let bio = profile.personal.biography {
                profilePageVC.addBioButton.isHidden = true
                profilePageVC.bioLabel.isHidden = false
                profilePageVC.bioLabel.text = bio
            } else {
                profilePageVC.addBioButton.isHidden = false
                profilePageVC.bioLabel.isHidden = true
            }
            
            // join date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
            profilePageVC.joinedDateLabel.text = ("Joined".localized() + " " + dateString)
            
            // count labels
            profilePageVC.followingsCountLabel.text = "\(profile.subscriptions.userIds.count)"
            profilePageVC.communitiesCountLabel.text = "\(profile.subscriptions.communities.count)"
            #warning("missing followers count")
            
            // save params
            profilePageVC.viewModel.updatemetaParams = profile.personal.blockchainParams
        }
    }
    
}


