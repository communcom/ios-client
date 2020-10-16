//
//  BasicEditorTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class BasicEditorTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        var attrs = super.defaultTypingAttributes
        attrs[.font] = UIFont.systemFont(ofSize: 17)
        attrs[.foregroundColor] = UIColor.appBlackColor
        return attrs
    }
    
    override var draftKey: String { "BasicEditorTextView.draftKey" }
    
    override var acceptedPostType: String {
        return "basic"
    }
    
    override var canContainAttachments: Bool {
        return false
    }
    
    override var contextMenuItems: [UIMenuItem] {
        return []
    }
    
    // MARK: - Link
    func addLink(_ urlString: String, placeholder: String?) {
        let placeholder = placeholder ?? urlString
        var attrs = typingAttributes
        attrs[.link] = urlString
        let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
        textStorage.replaceCharacters(in: selectedRange, with: attrStr)
        let newSelectedRange = NSRange(location: selectedRange.location + attrStr.length, length: 0)
        selectedRange = newSelectedRange
        typingAttributes = defaultTypingAttributes
    }
    
    override func getContentBlock() -> Single<ResponseAPIContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt64 = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ResponseAPIContentBlock>]()
        
        // change all \n to \r
        let aStr = attributedString.replaceOccurents(of: "\r", with: "\n")
        
        // separate blocks by \r
        let components = aStr.components(separatedBy: "\n")
        
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
                        type: self.acceptedPostType,
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
                block.maxId = id
                return block
        }
    }
}
