//
//  UIColor.swift
//  Commun
//
//  Created by Chung Tran on 26/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UIColor {
    static var appGrayColor: UIColor {
        return UIColor(hexString: "#A5A7BD")!
    }

    static var appLightGrayColor: UIColor {
        return UIColor(hexString: "#F3F5FA")!
    }

    static var appMainColor: UIColor {
        return UIColor(hexString: "#6A80F5")!
    }

    static var appRedColor: UIColor {
        return UIColor(hexString: "#F53D5B")!
    }

    static var appGreenColor: UIColor {
        return UIColor(hexString: "#4EDBB0")!
    }
    
    static var link: UIColor {
        return .init(red: 50/255, green: 146/255, blue: 252/255, alpha: 1)
    }
    
    static var a5a7bd: UIColor {
        return UIColor(hexString: "#A5A7BD")!
    }
    
    static var e5e5e5: UIColor {
        return UIColor(hexString: "#E5E5E5")!
    }
    
    static var plus: UIColor {
        return UIColor(hexString: "#4EDBB0")!
    }
    
    static var a7a9bf: UIColor {
        return UIColor(hexString: "#A7A9BF")!
    }
    
    static var f3f5fa: UIColor {
        return UIColor(hexString: "#F3F5FA")!
    }
    
    static var f7f7f9: UIColor {
        return UIColor(hexString: "#F7F7F9")!
    }
    
    static var e2e6e8: UIColor {
        return UIColor(hexString: "#E2E6E8")!
    }
    
    static var ed2c5b: UIColor {
        return UIColor(hexString: "#ED2C5B")!
    }
    
    static var shadow: UIColor {
        return UIColor(hexString: "#383C47")!
    }

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()

        Scanner(string: hex).scanHexInt32(&int)
        let alpha, red, green, blue: UInt32

        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)

        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)

        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)

        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }
}
