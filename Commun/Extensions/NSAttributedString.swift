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
    
    func components(separatedBy string: String) -> [NSAttributedString] {
        let input = self.string
        let separatedInput = input.components(separatedBy: string)
        var output = [NSAttributedString]()
        var start = 0
        for sub in separatedInput {
            let range = NSMakeRange(start, sub.count)
            let attrStr = attributedSubstring(from: range)
            output.append(attrStr)
            start += range.length + string.count
        }
        return output
    }
}
