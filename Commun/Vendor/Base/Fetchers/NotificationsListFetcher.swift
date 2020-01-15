//
//  NotificationsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class NotificationListFetcher: ListFetcher<ResponseAPIGetNotificationItem> {
    // MARK: - Nested type
    struct Filter: FilterType {
        var beforeThan: String?
        var filter = [String]()
    }
    
    var filter: Filter
    var lastNotificationTimestamp: String?
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
        limit = 20
    }
    
    override var request: Single<[ResponseAPIGetNotificationItem]> {
        RestAPIManager.instance.getNotifications(limit: limit, beforeThan: filter.beforeThan, filter: filter.filter)
            .map {result in
                self.lastNotificationTimestamp = result.lastNotificationTimestamp
                return result.items
            }
    }
}
