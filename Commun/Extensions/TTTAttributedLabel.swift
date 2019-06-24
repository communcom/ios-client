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
            let range = (content as NSString).range(of: "@\(user)")
            addLink(to: URL(string: "https://commun.com/@\(user)"), with: range)
        }
        for tag in content.getTags() {
            let range = (content as NSString).range(of: "#\(tag)")
            addLink(to: URL(string: "https://commun.com/#\(tag)"), with: range)
        }
    }
}
