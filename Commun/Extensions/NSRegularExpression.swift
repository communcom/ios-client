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
        return try? NSRegularExpression(pattern: "\\b(https:\\/\\/)?[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+(\\.[A-Za-z0-9_-]+)?(\\/[A-Za-z0-9_-]+)*", options: .caseInsensitive)
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
}
