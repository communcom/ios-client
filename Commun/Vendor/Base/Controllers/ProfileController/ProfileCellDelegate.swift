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
        NetworkService.shared.triggerFollow(user: profile)
            .subscribe(onError: { (error) in
                UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: self.disposeBag)
    }
}
