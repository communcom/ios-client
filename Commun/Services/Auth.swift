//
//  Auth.swift
//  Commun
//
//  Created by Chung Tran on 03/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

struct Auth {
    static func logout() {
        // Remove all keys
        let keys = [
            Config.currentUserNickNameKey,
            Config.currentUserAvatarUrlKey,
            Config.isCurrentUserLoggedKey
        ]
        keys.forEach { (key) in
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Notify
        WebSocketManager.instance.authorized.accept(false)
    }
}
