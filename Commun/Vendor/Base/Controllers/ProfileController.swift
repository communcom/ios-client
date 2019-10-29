//
//  ProfileController.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

let ProfileControllerProfileDidChangeNotification = "ProfileControllerProfileDidChangeNotification"

protocol ProfileController: class {
    var disposeBag: DisposeBag {get}
    var followButton: CommunButton {get set}
    var profile: ResponseAPIContentGetProfile? {get set}
    func setUp(with profile: ResponseAPIContentGetProfile)
}

extension ProfileController {
    func observeProfileChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: ProfileControllerProfileDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newProfile = notification.object as? ResponseAPIContentGetProfile,
                    newProfile == self.profile
                    else {return}
                self.setUp(with: newProfile)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleFollow() {
        guard profile != nil, let userId = profile?.userId else {return}
        
        let originIsFollowing = profile?.isSubscribed ?? false
        
        // set value
        setIsSubscribed(!originIsFollowing)
        
        // animate
        animateFollow()
        
        // notify changes
        profile!.notifyChanged()
        
        // send request
        NetworkService.shared.triggerFollow(userId, isUnfollow: originIsFollowing)
            .do(onSubscribe: { [weak self] in
                self?.followButton.isEnabled = false
            })
            .subscribe(onCompleted: { [weak self] in
                // re-enable button state
                self?.followButton.isEnabled = true
                
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsSubscribed(originIsFollowing)
                strongSelf.profile!.notifyChanged()
                
                // re-enable button state
                strongSelf.followButton.isEnabled = true
                
                // show error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func setIsSubscribed(_ value: Bool) {
        guard profile != nil,
            value != profile?.isSubscribed
        else {return}
        profile!.isSubscribed = value
        var subscribersCount: UInt64 = (profile!.subscribers?.usersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0}
        else {
            if value == true {
                subscribersCount += 1
            }
            else {
                subscribersCount -= 1
            }
        }
        profile!.subscribers?.usersCount = subscribersCount
    }
    
    func animateFollow() {
        
    }
}
