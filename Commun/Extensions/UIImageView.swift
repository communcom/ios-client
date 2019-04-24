//
//  UIImageView.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import UIImageView_Letters

fileprivate var nonAvatarColors = [String: UIColor]()

extension UIImageView {
    func setNonAvatarImageWithId(_ id: String) {
        var color = nonAvatarColors[id]
        if color == nil {
            repeat {
                color = UIColor.random
            } while nonAvatarColors.contains {$1==color}
            nonAvatarColors[id] = color
        }
        
        setImageWith(id, color: color)
    }
}
