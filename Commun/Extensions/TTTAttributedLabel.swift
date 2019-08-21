//
//  TTTAttributedLabel.swift
//  Commun
//
//  Created by Chung Tran on 21/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import TTTAttributedLabel

extension TTTAttributedLabel {
    func highlightTagsAndUserNames() {
        guard let content = self.text as? String else {return}
        if let regex = try? NSRegularExpression(pattern: "\(String.mentionRegex)", options: .caseInsensitive) {
            let string = content as NSString
            
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
            }

            for user in matches {
                addLinkToText(user, toUrl: "https://commun.com/\(user)")
            }
        }
        
        if let regex = try? NSRegularExpression(pattern: "\(String.tagRegex)", options: .caseInsensitive) {
            let string = content as NSString
            
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
            }
            
            for tag in matches {
                addLinkToText(tag, toUrl: "https://commun.com/\(tag)")
            }
        }
        
    }
    
    func addLinkToText(_ text: String, toUrl urlString: String? = nil) {
        guard let content = self.text as? String,
            let url = URL(string: urlString ?? text) else {return}
        let range = (content as NSString).range(of: text)
        addLink(to: url, with: range)
    }
}
