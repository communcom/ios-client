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
    static func logout() throws {
        // Remove all keys
        try KeychainManager.deleteUser()
        
        UserDefaults.standard.removeObject(forKey: Config.registrationUserPhoneKey)
        UserDefaults.standard.removeObject(forKey: Config.isCurrentUserLoggedKey)
        PDFManager.deletePDFDocument()
        WebSocketManager.instance.disconnect()
        WebSocketManager.instance.connect()
        
    }
}
