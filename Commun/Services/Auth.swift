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
    static func logout() -> Bool {
        // Remove all keys
        let result = KeychainManager.deleteAllData(forUserNickName: Config.currentUserIDKey)
//        let result = KeychainManager.deleteAllData(forUserNickName: Config.currentUser.id!)

        if result {
            UserDefaults.standard.removeObject(forKey: Config.isCurrentUserLoggedKey)
            WebSocketManager.instance.disconnect()
            WebSocketManager.instance.connect()
//            WebSocketManager.instance.authorized.accept(false)
        }
        
        return result
    }
}
