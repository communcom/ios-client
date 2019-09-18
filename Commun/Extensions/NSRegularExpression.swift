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
        return try? NSRegularExpression(pattern: #"_^(?:(?:https?|ftp)://)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)(?:\.(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)*(?:\.(?:[a-z\x{00a1}-\x{ffff}]{2,})))(?::\d{2,5})?(?:/[^\s]*)?$_iuS"#, options: .caseInsensitive)
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
