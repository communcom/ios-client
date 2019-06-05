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
            
            // user name
            profilePageVC.userNameLabel.text = profile.username ?? profile.userId
            
            // bio
            profilePageVC.bioLabel.text = profile.personal.biography
            
            // join date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
            profilePageVC.joinedDateLabel.text = ("Joined".localized() + " " + dateString)
            
            // count labels
            profilePageVC.followingsCountLabel.text = "\(profile.subscribers?.usersCount ?? 0)"
            profilePageVC.communitiesCountLabel.text = "\(profile.subscribers?.communitiesCount ?? 0)"
            #warning("missing followers count")
        }
    }
    
}


