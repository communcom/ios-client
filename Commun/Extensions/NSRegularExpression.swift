//
//  NSRegularExpression.swift
//  Commun
//
//  Created by Chung Tran on 9/18/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    static var linkRegex: NSRegularExpression? {
        // regex from @diegoperini
        // https://mathiasbynens.be/demo/url-regex
        return try? NSRegularExpression(pattern: linkRegexPattern, options: .caseInsensitive)
    }
    
    static var linkRegexPattern: String {
        return "\\b(https:\\/\\/)?(www\\.)?((?!www\\.)[A-Za-z0-9_-]+)\\.[A-Za-z0-9_-]+(\\.[A-Za-z0-9_-]+)?(\\/[A-Za-z0-9_-]+)*"
    }
    
    static var nameRegexPattern: String {
        return "[\\p{L}0-9-_]+"
    }
    
    static var mentionRegexPattern: String {
        return "\\B@\(nameRegexPattern)"
    }
    
    static var tagRegexPattern: String {
        return "\\B#\(nameRegexPattern)"
    }
    
    static var linkToTagRegexPattern: String {
        return escapedPattern(for: URL.appURL + "/") + tagRegexPattern
    }
    
    static var linkToMentionRegexPattern: String {
        return escapedPattern(for: URL.appURL + "/") + mentionRegexPattern
    }
    
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
        
        for original in originals {
            result = result.replacingOccurrences(of: original, with: templateForEach(original))
        }
        return result
    }
}
