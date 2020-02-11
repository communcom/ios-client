//
//  UserDefaults+Extensions.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 30.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit

public let appShareExtensionKey: String = "appShareExtensionKey"

extension UserDefaults {
    #if APPSTORE
        private static let groupID = "group.com.commun.ios"
    #else
        private static let groupID = "group.io.commun.eos.ios"
    #endif
    
    static let appGroups = UserDefaults(suiteName: groupID)!

    func loadShareExtensionData() -> ShareExtensionData? {
        let decoder = JSONDecoder()

        guard let decodedObject = UserDefaults.appGroups.object(forKey: appShareExtensionKey) as? Data else { return nil }
                
        guard let shareExtensionData = try? decoder.decode(ShareExtensionData.self, from: decodedObject) else { return nil }
        
        return shareExtensionData
    }
    
    func save(shareExtensionData: ShareExtensionData) -> Bool {
        let encoder = JSONEncoder()
        
        UserDefaults.appGroups.removeObject(forKey: appShareExtensionKey)

        guard let encodedData = try? encoder.encode(shareExtensionData) else { return false }

        UserDefaults.appGroups.set(encodedData, forKey: appShareExtensionKey)

        guard UserDefaults.appGroups.loadShareExtensionData() != nil else { return false }
        
        return true
    }
}
