//
//  NSRegularExpressionExtension.swift
//  Commun
//
//  Created by Chung Tran on 8/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    func matchedStrings(in string: String) -> [String] {
        let strings = matches(in: string, options: [], range: NSMakeRange(0, string.count))
            .map {
                string.nsString.substring(with: $0.range)
        }
        return Array(Set(strings))
    }
    
    func stringByReplacingMatches(in string: String, templateForEach: ((String) -> String)) -> String {
        let originals = matchedStrings(in: string)
        var result = string
        
        for index in 0..<originals.count {
            result = result.replacingOccurrences(of: originals[index], with: templateForEach(originals[index]))
        }
        return result
    }
}
