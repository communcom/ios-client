//
//  NotificationsPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class NotificationsPageViewModel: ListViewModel<ResponseAPIGetNotificationItem> {
    var filter: BehaviorRelay<NotificationListFetcher.Filter>
    
    init() {
        let filter = NotificationListFetcher.Filter(beforeThan: nil, filter: [])
        self.filter = BehaviorRelay<NotificationListFetcher.Filter>(value: filter)
        super.init(fetcher: NotificationListFetcher(filter: filter))
        defer {
            bindFilter()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
            .subscribe(onNext: { filter in
                self.fetcher.reset()
                (self.fetcher as! NotificationListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
}
