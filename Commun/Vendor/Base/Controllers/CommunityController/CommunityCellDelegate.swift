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
        var community = community
        // for reverse
        let originIsSubscribed = community.isSubscribed ?? false
        
        // set value
        community.setIsSubscribed(!originIsSubscribed)
        community.isBeingJoined = true
        
        // notify changes
        community.notifyChanged()
        
        let request: Completable
        
        if originIsSubscribed {
            request = RestAPIManager.instance.unfollowCommunity(community.communityId)
                .flatMapToCompletable()
        }
        else {
            request = RestAPIManager.instance.followCommunity(community.communityId)
                .flatMapToCompletable()
        }
        
        request
            .subscribe(onCompleted: {
                // re-enable state
                community.isBeingJoined = false
                community.notifyChanged()
                
            }) { [weak self] (error) in
                // reverse change
                community.setIsSubscribed(originIsSubscribed)
                community.isBeingJoined = false
                community.notifyChanged()
                
                // show error
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
