//
//  CommentTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

class CommentTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        return [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.appBlackColor]
    }
    
    override func commonInit() {
        super.commonInit()
        textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    override func clearFormatting() {
        if selectedRange.length <= 1 {
            typingAttributes = defaultTypingAttributes
        } else {
            textStorage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, _) in
                if let link = attrs[.link] as? String {
                    if link.isLinkToTag || link.isLinkToMention {
                        return
                    }
                }
                textStorage.setAttributes(defaultTypingAttributes, range: range)
            }
        }
    }
    
    override var contextMenuItems: [UIMenuItem] {
        var items = super.contextMenuItems
        // don't allow add link
        items = items.filter {$0.title != "🔗"}
        return items
    }
    
    override func getContentBlock() -> Single<ResponseAPIContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt64 = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ResponseAPIContentBlock>]()
        
        // separate blocks by \n
        let components = attributedString.components(separatedBy: "\n")
        
        for component in components {
            if let block = component.toParagraphContentBlock(id: &id) {
                contentBlocks.append(.just(block))
            }
        }
        
        return Single.zip(contentBlocks)
            .map {contentBlocks -> ResponseAPIContentBlock in
                var block = ResponseAPIContentBlock(
                    id: 1,
                    type: "document",
                    attributes: ResponseAPIContentBlockAttributes(
                        type: "comment",
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
                block.maxId = id
                return block
        }
    }
}
