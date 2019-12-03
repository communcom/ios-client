//
//  CommunityCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

protocol CommunityCellDelegate: class {
    func buttonFollowDidTouch<T: CommunityType>(community: T)
    func forceFollow<T: CommunityType>(_ value: Bool, community: T)
}

extension CommunityCellDelegate where Self: BaseViewController {
    func buttonFollowDidTouch<T: CommunityType>(community: T) {
        NetworkService.shared.triggerFollow(community: community)
            .subscribe { [weak self] (error) in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func forceFollow<T: CommunityType>(_ value: Bool, community: T) {
        var community = community
        
        community.isSubscribed = !value
        
        buttonFollowDidTouch(community: community)
    }
}
