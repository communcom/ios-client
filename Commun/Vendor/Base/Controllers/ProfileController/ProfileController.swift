//
//  ProfileController.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

protocol ProfileType: ListItemType {
    var userId: String {get}
    var username: String {get}
    var isSubscribed: Bool? {get set}
    var subscribersCount: UInt64? {get set}
    var identity: String {get}
    var isBeingToggledFollow: Bool? {get set}
    var isInBlacklist: Bool? {get set}
}

extension ProfileType {
    mutating func setIsSubscribed(_ value: Bool) {
        guard value != isSubscribed
        else {return}
        isSubscribed = value
        var subscribersCount: UInt64 = (self.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0} else {
            if value == true {
                subscribersCount += 1
            } else {
                subscribersCount -= 1
            }
        }
        self.subscribersCount = subscribersCount
    }
}

extension ResponseAPIContentGetProfile: ProfileType {
    var subscribersCount: UInt64? {
        get {
            return subscribers?.usersCount
        }
        set {
            subscribers?.usersCount = newValue
        }
    }
}
extension ResponseAPIContentGetSubscriptionsUser: ProfileType {}
extension ResponseAPIContentResolveProfile: ProfileType {}

protocol ProfileController: class {
    associatedtype Profile: ProfileType
    var disposeBag: DisposeBag {get}
    var followButton: CommunButton {get set}
    var profile: Profile? {get set}
    func setUp(with profile: Profile)
}

extension ProfileController {
    func observeProfileChange() {
        Profile.observeItemChanged()
            .filter {$0.identity == self.profile?.identity}
            .subscribe(onNext: {newProfile in
                self.setUp(with: newProfile)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleFollow() {
        guard let profile = profile,
            let vc = UIApplication.topViewController()
        else {return}
        
        if profile.isInBlacklist == true
        {
            vc.showAlert(title: "unblock and follow".localized().uppercaseFirst, message: "this user is on your blacklist. Do you really want to unblock and follow him/her anyway?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
            { (index) in
                if index == 0 {
                    self.sendRequest()
                }
            })
        } else {
            self.sendRequest()
        }
    }
    
    private func sendRequest() {
        guard let profile = profile else {return}
        followButton.animate {
            NetworkService.shared.triggerFollow(user: profile)
                .subscribe(onError: { (error) in
                    UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
}
