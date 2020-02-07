//
//  SubscriptionsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsViewModel: ListViewModel<ResponseAPIContentGetSubscriptionsItem> {
    let type: GetSubscriptionsType
    init(userId: String? = nil, type: GetSubscriptionsType, initialItems: [ResponseAPIContentGetSubscriptionsItem]? = nil) {
        var userId = userId
        if userId == nil {
            userId = Config.currentUser?.id ?? ""
        }
        let fetcher = SubscriptionsListFetcher(userId: userId!, type: type)
        self.type = type
        super.init(fetcher: fetcher)
        
        defer {
            if let initItems = initialItems {
                items.accept(initItems)
            } else {
                fetchNext()
            }
            
            observeProfileBlocked()
        }
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetProfile.observeItemDeleted()
            .subscribe(onNext: { (deletedUser) in
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.user(deletedUser))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemDeleted()
            .subscribe(onNext: { (deletedCommunity) in
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.community(deletedCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemChange() {
        ResponseAPIContentGetProfile.observeItemChanged()
            .subscribe(onNext: { (newItem) in
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.user(newItem))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: {newCommunity in
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    func observeProfileBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                self.deleteItemWithIdentity(blockedProfile.identity)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                self.deleteItemWithIdentity(blockedProfile.identity)
            })
            .disposed(by: disposeBag)
    }
}
