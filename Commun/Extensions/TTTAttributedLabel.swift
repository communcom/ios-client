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
        for user in content.getMentions() {
            addLinkToText("@\(user)", toUrl: "https://commun.com/@\(user)")
        }
        for tag in content.getTags() {
            addLinkToText("#\(tag)", toUrl: "https://commun.com/#\(tag)")
        }
    }
    
    func addLinkToText(_ text: String, toUrl urlString: String? = nil) {
        guard let content = self.text as? String,
            let url = URL(string: urlString ?? text) else {return}
        let range = (content as NSString).range(of: text)
        addLink(to: url, with: range)
    }
}
