//
//  CommentTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommentTextView: ContentTextView {
    override func awakeFromNib() {
        defaultTypingAttributes = [.font: UIFont.systemFont(ofSize: 14)]
        super.awakeFromNib()
    }
    
    override func clearFormatting() {
        if selectedRange.length == 0 {
            typingAttributes = defaultTypingAttributes
        }
        else {
            textStorage.enumerateAttributes(in: selectedRange, options: []) {
                (attrs, range, stop) in
                if let link = attrs[.link] as? String {
                    if link.isLinkToTag || link.isLinkToMention {
                        return
                    }
                }
                textStorage.setAttributes(defaultTypingAttributes, range: range)
            }
        }
    }
}
