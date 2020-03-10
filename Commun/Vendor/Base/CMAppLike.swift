//
//  CMAppLike.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 03.03.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

struct CMAppLike: Codable {
    // MARK: - Properties
    var wasShowing: Bool
    var currentVersion: UInt64
    
    
    // MARK: - Functions
    static func verify() -> Bool {
        let appLike = read()
        
        if appLike.currentVersion < Bundle.main.minorVersion {
            save(CMAppLike(wasShowing: false, currentVersion: Bundle.main.minorVersion))
            return false
        }
        
        return appLike.wasShowing
    }
    
    private static func read() -> CMAppLike {
        let decoder = JSONDecoder()
        
        guard let savedAppLike = UserDefaults.standard.object(forKey: "CMAppLike") as? Data, let loadedAppLike = try? decoder.decode(CMAppLike.self, from: savedAppLike) else {
            let appLike = CMAppLike(wasShowing: false, currentVersion: Bundle.main.minorVersion)
            save(appLike)
            
            return appLike
        }
        
        return loadedAppLike
    }
    
    private static func save(_ appLike: CMAppLike) {
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(appLike) {
            UserDefaults.standard.set(encoded, forKey: "CMAppLike")
        }
    }
    
    static func updateRate() {
        var appLike = read()
        appLike.wasShowing = true
        
        save(appLike)
    }
    
//    func rateApplication() -> Bool {
//
//    }
}
