//
//  LAContext.swift
//  Commun
//
//  Created by Chung Tran on 19/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import LocalAuthentication
import CyberSwift

extension LABiometryType {
    var icon: UIImage? {
        switch self {
        case .touchID:
            return UIImage(named: "boarding-touch-id")!
        case .faceID:
            return UIImage(named: "boarding-face-id")!
        default:
            return nil
        }
    }
    
    var stringValue: String {
        switch self {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        default:
            return ""
        }
    }
    
    static var current: LABiometryType {
        // retrieve policy
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    static var isEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Config.currentUserBiometryAuthEnabled)
    }
}
