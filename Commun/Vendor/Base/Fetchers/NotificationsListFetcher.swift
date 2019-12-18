//
//  NotificationsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class NotificationsListFetcher: ListFetcher<ResponseAPIOnlineNotificationData> {
    override var request: Single<[ResponseAPIOnlineNotificationData]> {
        return NetworkService.shared.getNotifications(fromId: nil)
            .map {$0.data}
    }
}
