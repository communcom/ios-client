//
//  ResponseAPIOnlineNotificationData.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIOnlineNotificationData: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIOnlineNotificationData, rhs: ResponseAPIOnlineNotificationData) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return self._id
    }
}
