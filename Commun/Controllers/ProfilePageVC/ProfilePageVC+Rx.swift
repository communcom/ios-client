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
            if !profilePageVC.viewModel.isMyProfile {
                // set title
                profilePageVC.title = profile.username ?? profile.userId
                
                // follow button
                let isFollowing = profile.isSubscribed ?? false
                profilePageVC.followButton.setImage(UIImage(named: isFollowing ? "ProfilePageFollowing": "ProfilePageFollow"), for: .normal)
                profilePageVC.followLabel.text = (isFollowing ? "following" : "follow").localized().uppercaseFirst
                profilePageVC.followButton.backgroundColor = isFollowing ? UIColor(hexString: "#F5F5F5") : .appMainColor
                profilePageVC.followLabel.textColor = isFollowing ? UIColor(hexString: "#9B9FA2") : .appMainColor
            }
            
            // cover image
            if let coverUrl = profile.personal.coverUrl {
                profilePageVC.userCoverImage.sd_setImage(with: URL(string: coverUrl), placeholderImage: UIImage(named: "ProfilePageCover"))
            }
            
            // profile image
            if !profilePageVC.viewModel.isMyProfile {
                profilePageVC.userAvatarImage.setAvatar(urlString: profile.personal.avatarUrl, namePlaceHolder: profile.username ?? profile.userId)
            }
            
            // user name
            profilePageVC.userNameLabel.text = profile.username ?? profile.userId
            
            // bio
            profilePageVC.bioLabel.text = profile.personal.biography
            
            // join date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
            profilePageVC.joinedDateLabel.text = String(format: "%@ %@", "joined".localized().uppercaseFirst, dateString)
            
            // count labels
            #warning("fix these number later")
            profilePageVC.followersCountLabel.text = "\(profile.subscribers?.usersCount ?? 0)"
            profilePageVC.followingsCountLabel.text = "\(profile.subscriptions?.usersCount ?? 0)"
            profilePageVC.communitiesCountLabel.text = "\(profile.subscriptions?.communitiesCount ?? 0)"
        }
    }
    
}


