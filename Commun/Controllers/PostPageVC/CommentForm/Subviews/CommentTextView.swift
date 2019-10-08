//
//  CommentTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommentTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: UIFont.systemFont(ofSize: 14)]
    }
    
    override func commonInit() {
        super.commonInit()
        textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
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
