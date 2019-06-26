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
    
    fileprivate func getStringsStartWith(_ symbol: String) -> [String] {
        if let regex = try? NSRegularExpression(pattern: "\(symbol)[a-z0-9]+", options: .caseInsensitive)
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
    
    func highlightMentionAttributedString() -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: self)
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive){
            for match in regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: match.range)
                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: match.range)
            }
        }
        if let regex = try? NSRegularExpression(pattern: "@[a-z0-9]+", options: .caseInsensitive){
            for match in regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: match.range)
                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: match.range)
            }
        }
        return attributed
    }
    
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
    
}
