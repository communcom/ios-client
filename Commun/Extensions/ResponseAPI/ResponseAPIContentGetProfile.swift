//
//  ResponseAPIContentGetProfile.swift
//  Commun
//
//  Created by Chung Tran on 25/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetProfile: Equatable, IdentifiableType {
    mutating func triggerFollow() {
        isSubscribed = !(isSubscribed ?? false)
        if (isSubscribed!) {
            let usersCount = (subscribers?.usersCount ?? 0) + 1
            subscribers?.usersCount = usersCount
        } else {
            let usersCount = (subscribers?.usersCount ?? 1) - 1
            subscribers?.usersCount = usersCount
        }
    }
    
    public static func == (lhs: ResponseAPIContentGetProfile, rhs: ResponseAPIContentGetProfile) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return userId + "/" + (username ?? "")
    }
    
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileControllerProfileDidChangeNotification), object: self)
    }
}
