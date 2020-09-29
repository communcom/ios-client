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
        #colorLiteral(red: 0.6470588235, green: 0.6549019608, blue: 0.7411764706, alpha: 1).inDarkMode(#colorLiteral(red: 0.4156862745, green: 0.4235294118, blue: 0.4784313725, alpha: 1))
    }

    static var appLightGrayColor: UIColor {
        #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1).inDarkMode(#colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1568627451, alpha: 1))
    }

    static var appMainColor: UIColor {
        #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1).inDarkMode(#colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1))
    }
    
    static var appMainColorDarkBlack: UIColor {
        #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1).inDarkMode(#colorLiteral(red: 0.1725490196, green: 0.1843137255, blue: 0.2117647059, alpha: 1))
    }

    static var appRedColor: UIColor {
        #colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.3568627451, alpha: 1).inDarkMode(#colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.3568627451, alpha: 1))
    }

    static var appGreenColor: UIColor {
        #colorLiteral(red: 0.3058823529, green: 0.8588235294, blue: 0.6901960784, alpha: 1).inDarkMode(#colorLiteral(red: 0.3058823529, green: 0.8588235294, blue: 0.6901960784, alpha: 1))
    }

    static var appWhiteColor: UIColor {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).inDarkMode(#colorLiteral(red: 0.1725490196, green: 0.1843137255, blue: 0.2117647059, alpha: 1))
    }

    static var appBlackColor: UIColor {
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).inDarkMode(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }

    static var disableShadowDark: UIColor {
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).inDarkMode(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }

    static func onlyLightModeShadowColor(_ color: UIColor) -> UIColor {
        color.inDarkMode(.clear)
    }
    
    static var link: UIColor {
        #colorLiteral(red: 0.1960784314, green: 0.5725490196, blue: 0.9882352941, alpha: 1).inDarkMode(#colorLiteral(red: 0.1960784314, green: 0.5725490196, blue: 0.9882352941, alpha: 1))
    }
    
    static var shadow: UIColor {
        return .black
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
    
    func inDarkMode(_ color: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return color
                } else {
                    return self
                }
            }
        }
        return self
    }
    
    // MARK: - Others
    static var e2e6e8: UIColor {
        UIColor(hexString: "#e2e6e8")!.inDarkMode(.white)
    }
}
