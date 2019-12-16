//
//  NotificationsPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright (c) 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import CyberSwift

class NotificationsViewModel: ListViewModel<ResponseAPIOnlineNotificationData> {
    convenience init() {
        let fetcher = NotificationsListFetcher()
        self.init(fetcher: fetcher)
        defer {
            fetchNext()
        }
    }
    
    func markAsRead(_ item: ResponseAPIOnlineNotificationData) -> Completable {
        return NetworkService.shared.markAsRead(ids: [item._id])
    }
}
