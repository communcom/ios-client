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
                guard let newProfile = self.profile?.newUpdatedItem(from: newProfile) else {return}
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
            vc.showAlert(title: "unblock and follow".localized().uppercaseFirst, message: "this user is on your blacklist".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
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
            BlockchainManager.instance.triggerFollow(user: profile)
                .subscribe(onError: { (error) in
                    UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
}
