//
//  UIView+Shadow.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UIView {
    @IBInspectable var defaultShadow: Bool {
        get {
            return layer.shadowPath != nil ? true: false
        }
        set {
            if (newValue == false) {
                layer.masksToBounds = true
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.shadowOpacity = 0
                layer.shadowPath = nil
            } else {
                layer.masksToBounds = false
                layer.shadowOffset = CGSize(width: 5, height: 5)
                layer.shadowOpacity = 0.1
                layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            }
        }
    }
}
