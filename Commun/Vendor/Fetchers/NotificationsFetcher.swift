//
//  NotificationsFetcher.swift
//  Commun
//
//  Created by Chung Tran on 14/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class NotificationsFetcher: ItemsFetcher<ResponseAPIOnlineNotificationData> {
    override var request: Single<[ResponseAPIOnlineNotificationData]>! {
        return NetworkService.shared.getNotifications(fromId: nil)
            .map {$0.data}
    }
}
