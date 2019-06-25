//
//  ResponseAPIContentGetProfile.swift
//  Commun
//
//  Created by Chung Tran on 25/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension ResponseAPIContentGetProfile {
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
}
