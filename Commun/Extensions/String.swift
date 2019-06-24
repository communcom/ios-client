//
//  String.swift
//  Commun
//
//  Created by Chung Tran on 07/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension String {
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
