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
        guard let decodedObject = UserDefaults.appGroups.object(forKey: appShareExtensionKey) as? Data else { return nil }
        
        let shareExtensionData = ShareExtensionData()
        
        if let dictionary = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedObject) as? [String: Any] {
            if let text = dictionary["text"] as? String {
                shareExtensionData.text = text
            }
            
            if let url = dictionary["url"] as? String {
                shareExtensionData.link = url
            }

            if let image = dictionary["image"] as? UIImage {
                shareExtensionData.image = image
            }
            
            return shareExtensionData
        } else {
            return nil
        }
    }
    
    func save(shareExtensionData: ShareExtensionData) -> Bool {
        var dictionary = [String: Any]()
        
        if let image = shareExtensionData.image {
            dictionary["image"] = image
        }
        
        if let text = shareExtensionData.text {
            dictionary["text"] = text
        }

        if let url = shareExtensionData.link {
            dictionary["url"] = url
        }

        guard let encodedData: Data = try? NSKeyedArchiver.archivedData(withRootObject: dictionary) else { return false }
//        archivedData(withRootObject: dictionary, requiringSecureCoding: false) else { return false }
//        guard let encodedData: Data = try? NSKeyedArchiver.archivedData(withRootObject: shareExtensionData, requiringSecureCoding: false) else { return false }

        UserDefaults.appGroups.set(encodedData, forKey: appShareExtensionKey)
        
        return true
    }
}
