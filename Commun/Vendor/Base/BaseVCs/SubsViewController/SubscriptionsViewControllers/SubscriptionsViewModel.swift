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
    
    override func observeItemChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(Self.self)DidChange"))
            .subscribe(onNext: { (notification) in
                if let newItem = notification.object as? ResponseAPIContentGetSubscriptionsUser
                {
                    self.updateItem(ResponseAPIContentGetSubscriptionsItem.user(newItem))
                }
                if let newItem = notification.object as? ResponseAPIContentGetSubscriptionsCommunity
                {
                    self.updateItem(ResponseAPIContentGetSubscriptionsItem.community(newItem))
                }
                return
            })
            .disposed(by: disposeBag)
    }
}
