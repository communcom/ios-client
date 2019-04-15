//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
}
