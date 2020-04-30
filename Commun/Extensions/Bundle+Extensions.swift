//
//  Bundle+Extensions.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 13.02.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Localize_Swift

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
    
    static func swizzleLocalization() {
        let orginalSelector = #selector(localizedString(forKey:value:table:))
        guard let orginalMethod = class_getInstanceMethod(self, orginalSelector) else { return }

        let mySelector = #selector(myLocaLizedString(forKey:value:table:))
        guard let myMethod = class_getInstanceMethod(self, mySelector) else { return }

        if class_addMethod(self, orginalSelector, method_getImplementation(myMethod), method_getTypeEncoding(myMethod)) {
            class_replaceMethod(self, mySelector, method_getImplementation(orginalMethod), method_getTypeEncoding(orginalMethod))
        } else {
            method_exchangeImplementations(orginalMethod, myMethod)
        }
    }

    @objc private func myLocaLizedString(forKey key: String, value: String?, table: String?) -> String {
        guard let bundlePath = Bundle.main.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: bundlePath) else {
                return Bundle.main.myLocaLizedString(forKey: key, value: value, table: table)
        }
        return bundle.myLocaLizedString(forKey: key, value: value, table: table)
    }
}
