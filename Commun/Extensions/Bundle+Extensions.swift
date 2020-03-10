//
//  Bundle+Extensions.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 13.02.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension Bundle {
    public var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var fullVersion: String {
        return String(format: "%@ %@, %@ %@", "version".localized().uppercaseFirst, shortVersion, "build".localized().uppercaseFirst, buildVersion)
    }
    
    public var minorVersion: UInt64 {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            let resultComponents = result.components(separatedBy: ".")
            return UInt64(resultComponents[0] + resultComponents[1]) ?? 0
        } else {
            assert(false)
            return 0
        }
    }
}
