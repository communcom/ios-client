//
//  ProfileCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 12/2/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol ProfileCellDelegate: class {
    func buttonFollowDidTouch<T: ProfileType>(profile: T)
}

extension ProfileCellDelegate where Self: BaseViewController {
    func buttonFollowDidTouch<T: ProfileType>(profile: T) {
        if profile.isInBlacklist == true
        {
            UIApplication.topViewController()?.showAlert(title: "\(profile is ResponseAPIContentGetProfile ? "unblock" : "unhide") and follow".localized().uppercaseFirst, message: "this \(profile is ResponseAPIContentGetProfile ? "user" : "community") is on your blacklist".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
                { (index) in
                    if index == 0 {
                        self.sendRequest(profile: profile)
                    }
            })
        } else {
            self.sendRequest(profile: profile)
        }
    }
    
    private func sendRequest<T: ProfileType>(profile: T) {
        BlockchainManager.instance.triggerFollow(user: profile)
            .subscribe(onError: { (error) in
                UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: self.disposeBag)
    }
}
