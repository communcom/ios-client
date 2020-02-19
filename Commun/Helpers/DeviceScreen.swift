//
//  DeviceScreen.swift
//  Commun
//
//  Created by Artem Shilin on 18.02.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit

enum DeviceScreen: CGFloat {
    case undefined = 0.0
    case iPhone5 = 568.0
    case iPhone6 = 667.0
    case iPhonePlus = 736.0
    case iPhoneX = 812.0
    case iPhone11ProMax = 896
    case iPad = 1024.0
    case iPadPro = 1366.0

    struct ScreenSize {
        static let width = UIScreen.main.bounds.width
        static let height = UIScreen.main.bounds.height
        static let lengthMax = max(ScreenSize.width, ScreenSize.height)
        static let lengthMin = min(ScreenSize.width, ScreenSize.height)
    }

    static func current() -> DeviceScreen {
        let model = DeviceScreen(rawValue: ScreenSize.lengthMax)
        return model ?? .undefined
    }

    enum Family {
        case iPad
        case iPhone5
        case iPhone6to8
        case iPhone6PlusTo8Plus
        case iPhoneXtoXSMax
    }

    static func getFamily() -> Family {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return .iPhone5
            case 1334:
                return .iPhone6to8
            case 1920, 2208:
                return .iPhone6PlusTo8Plus
            case 2436:
                return .iPhoneXtoXSMax
            case 2688:
                return .iPhoneXtoXSMax
            case 1792:
                return .iPhoneXtoXSMax
            default:
                return .iPhone5
            }
        } else {
            return .iPad
        }
    }
}
