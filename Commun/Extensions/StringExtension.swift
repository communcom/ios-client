//
//  StringExtension.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    static var invisible: String {
        return "\u{2063}"
    }
    
    func md5() -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    static var nameRegex: String {
        return "[\\p{L}0-9-_]+"
    }
    
    static var mentionRegex: String {
        return "\\B@\(nameRegex)"
    }
    
    static var tagRegex: String {
        return "\\B#\(nameRegex)"
    }
    
    fileprivate func getStringsStartWith(_ symbol: String) -> [String] {
        if let regex = try? NSRegularExpression(pattern: "\(symbol)\(String.nameRegex)", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: symbol, with: "").lowercased()
            }
        }
        
        return []
    }
    
    func getTags() -> [String] {
        return getStringsStartWith("#")
    }
    
    func getMentions() -> [String] {
        return getStringsStartWith("@")
    }
    
//    func highlightMentionAttributedString() -> NSAttributedString {
//        let attributed = NSMutableAttributedString(string: self)
//        if let regex = try? NSRegularExpression(pattern: "\\s" + .tagRegex, options: .caseInsensitive){
//            for match in regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)) as [NSTextCheckingResult] {
//                attributed.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: match.range)
//                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: match.range)
//            }
//        }
//        if let regex = try? NSRegularExpression(pattern: .mentionRegex, options: .caseInsensitive){
//            for match in regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)) as [NSTextCheckingResult] {
//                attributed.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: match.range)
//                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: match.range)
//            }
//        }
//        return attributed
//    }
    
    func getJsonMetadata() -> [[String: String]] {
        var embeds = [[String: String]]()
        
        for word in components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                if embeds.first(where: {$0["url"] == word}) != nil {continue}
                #warning("Define type")
                embeds.append(["url": word])
            }
        }
        return embeds
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    
    // MARK: - Telephone verification
    /// Fill missing number with dashes
    func fillWithDash(start: Int, offsetBy: Int) -> String {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return Array(0..<offsetBy).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        if let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) {
            return String(self[substringStartIndex ..< substringEndIndex])
        }
        
        var result = String(self[substringStartIndex...])
        
        if (result.count < offsetBy) {
            result += Array(0..<offsetBy-result.count).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        return result
    }
    
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func slicing(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
