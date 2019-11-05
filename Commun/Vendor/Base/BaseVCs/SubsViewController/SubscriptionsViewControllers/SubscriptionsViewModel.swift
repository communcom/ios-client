//
//  SubscriptionsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsViewModel: ListViewModel<ResponseAPIContentGetSubscriptionsItem> {
    let type: GetSubscriptionsType
    init(userId: String?, type: GetSubscriptionsType) {
        var userId = userId
        if userId == nil {
            userId = Config.currentUser?.id ?? ""
        }
        let fetcher = SubscriptionsListFetcher(userId: userId!, type: type)
        self.type = type
        super.init(fetcher: fetcher)
        
        defer {
            fetchNext()
        }
    }
    
    override func observeItemDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetSubscriptionsUser.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let deletedUser = notification.object as? ResponseAPIContentGetSubscriptionsUser
                    else {return}
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.user(deletedUser))
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetSubscriptionsCommunity.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let deletedCommunity = notification.object as? ResponseAPIContentGetSubscriptionsCommunity
                    else {return}
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.community(deletedCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetSubscriptionsUser.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newUser = notification.object as? ResponseAPIContentGetSubscriptionsUser
                    else {return}
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.user(newUser))
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetSubscriptionsCommunity.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? ResponseAPIContentGetSubscriptionsCommunity
                    else {return}
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
}
