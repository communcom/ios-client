//
//  UIApplication.swift
//  Commun
//
//  Created by Chung Tran on 17/05/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    class var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class var versionBuild: String {
        let version = appVersion, build = appBuild
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
