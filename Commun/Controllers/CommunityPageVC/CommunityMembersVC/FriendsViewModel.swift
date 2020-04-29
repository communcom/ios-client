//
//  FriendsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class FriendsViewModel: ListViewModel<ResponseAPIContentGetProfile> {
    init(friends: [ResponseAPIContentGetProfile]) {
        // dummy fetcher
        let fetcher = SubscribersListFetcher()
        super.init(fetcher: fetcher)
        defer {
            accept(friends)
        }
    }
    
    func accept(_ friends: [ResponseAPIContentGetProfile]) {
        let subscriptionsVM = SubscriptionsViewModel.ofCurrentUserTypeUser
        
        var friends = friends
        for i in 0..<friends.count {
            if let friend = subscriptionsVM.items.value.first(where: {$0.userValue?.identity == friends[i].identity})?.userValue
            {
                friends[i] = friend
            } else {
                friends[i].isSubscribed = true
            }
        }
        items.accept(friends)
    }
    
    override func updateItem(_ updatedItem: ResponseAPIContentGetProfile) {
        var newItems = fetcher.items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {
            if updatedItem.isSubscribed == true {
                let items = [updatedItem] + self.items.value
                self.items.accept(items)
            }
            return
        }
        
        if updatedItem.isSubscribed == false {
            var items = self.items.value
            items.removeAll(where: {updatedItem.identity == $0.identity})
            self.items.accept(items)
            return
        }
        guard let newUpdatedItem = newItems[index].newUpdatedItem(from: updatedItem) else {return}
        newItems[index] = newUpdatedItem
        fetcher.items.accept(newItems)
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
}
