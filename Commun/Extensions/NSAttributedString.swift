//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 8/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func nsRangeOfText(_ text: String) -> NSRange {
        let str1 = string.nsString
        return str1.range(of: text)
    }
}
