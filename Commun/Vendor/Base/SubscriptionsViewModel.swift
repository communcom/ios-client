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
    convenience init(userId: String?, type: GetSubscriptionsType) {
        var userId = userId
        if userId == nil {
            userId = Config.currentUser?.id ?? ""
        }
        let fetcher = SubscriptionsListFetcher(userId: userId!, type: type)
        self.init(fetcher: fetcher)
    }
}
