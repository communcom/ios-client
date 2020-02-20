//
//  SubscribersViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersViewModel: ListViewModel<ResponseAPIContentGetProfile> {
    convenience init(userId: String? = nil, communityId: String? = nil, prefetch: Bool = true) {
        let fetcher = SubscribersListFetcher()
        fetcher.userId = userId
        fetcher.communityId = communityId
        self.init(fetcher: fetcher, prefetch: prefetch)
        
        defer {
            observeProfileBlocked()
            if userId == Config.currentUser?.id {
                observeUserFollowed()
                observeUserUnfollowed()
            }
        }
    }
    
    override func observeItemChange() {
        super.observeItemChange()
        
        ResponseAPIContentGetLeader.observeItemChanged()
            .map {ResponseAPIContentGetProfile(leader: $0)}
            .subscribe(onNext: { (profile) in
                self.updateItem(profile)
            })
            .disposed(by: disposeBag)
    }
    
    func observeProfileBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                self.deleteItemWithIdentity(blockedProfile.identity)
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserFollowed() {
        // if current user follow someone
        ResponseAPIContentGetProfile.observeProfileFollowed()
            .filter {profile in
                !self.items.value.contains(where: {$0.identity == profile.identity})
            }
            .subscribe(onNext: { (followedProfile) in
                var newItems = [followedProfile]
                newItems.joinUnique(self.items.value)
                self.items.accept(newItems)
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserUnfollowed() {
        // if current user unfollow someone
        ResponseAPIContentGetProfile.observeProfileUnfollowed()
            .filter {profile in
                self.items.value.contains(where: {$0.identity == profile.identity})
            }
            .subscribe(onNext: { (unfollowedProfile) in
                self.deleteItemWithIdentity(unfollowedProfile.identity)
            })
            .disposed(by: disposeBag)
    }
}
