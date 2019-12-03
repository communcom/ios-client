//
//  FriendsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FriendsViewModel: ListViewModel<ResponseAPIContentResolveProfile> {
    init(friends: [ResponseAPIContentResolveProfile]) {
        // dummy fetcher
        let fetcher = SubscribersListFetcher()
        super.init(fetcher: fetcher)
        defer {
            accept(friends)
            observeFriendAdded()
            observeFriendRemoved()
        }
    }
    
    func accept(_ friends: [ResponseAPIContentResolveProfile]) {
        var friends = friends
        for i in 0..<friends.count {
            friends[i].isSubscribed = true
        }
        items.accept(friends)
    }
    
    func observeFriendAdded() {
        ResponseAPIContentResolveProfile.observeItemChanged()
            .filter {profile in
                !self.items.value.contains(where: {$0.identity == profile.identity}) &&
                profile.isSubscribed == true
            }
            .subscribe(onNext: { (profile) in
                let items = [profile] + self.items.value
                self.items.accept(items)
            })
            .disposed(by: disposeBag)
    }
    
    func observeFriendRemoved() {
        ResponseAPIContentResolveProfile.observeItemChanged()
            .filter {profile in
                self.items.value.contains(where: {$0.identity == profile.identity}) &&
                profile.isSubscribed == false
            }
            .subscribe(onNext: { (profile) in
                var items = self.items.value
                items.removeAll(profile)
                self.items.accept(items)
            })
            .disposed(by: disposeBag)
    }
}
