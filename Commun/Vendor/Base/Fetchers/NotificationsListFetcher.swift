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
        var filter: [String]?
    }
    
    var filter: Filter
    var lastNotificationTimestamp: String?
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
        limit = 20
    }
    
    override func reset(clearResult: Bool = true) {
        super.reset(clearResult: clearResult)
        filter.beforeThan = nil
    }
    
    override var request: Single<[ResponseAPIGetNotificationItem]> {
        RestAPIManager.instance.getNotifications(limit: limit, beforeThan: filter.beforeThan, filter: filter.filter)
//        ResponseAPIGetNotifications.singleWithMockData()
//            .delay(0.8, scheduler: MainScheduler.instance)
            .map {result in
                self.lastNotificationTimestamp = result.lastNotificationTimestamp
                self.filter.beforeThan = result.items.last?.timestamp
                return result.items
            }
    }
}
