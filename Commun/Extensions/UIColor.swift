//
//  UIImageView.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

fileprivate var nonAvatarColors = [String: UIColor]()

extension UIColor {
    static func avatarColorForUserWithId(_ id: String) -> UIColor {
        var color = nonAvatarColors[id]
        if color == nil {
            repeat {
                color = UIColor.random
            } while nonAvatarColors.contains {$1==color}
        }
        return color!
    }
}
