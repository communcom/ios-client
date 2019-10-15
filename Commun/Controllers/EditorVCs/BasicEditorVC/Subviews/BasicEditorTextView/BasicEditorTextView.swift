//
//  BasicEditorTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class BasicEditorTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        var attrs = super.defaultTypingAttributes
        attrs[.font] = UIFont.systemFont(ofSize: 17)
        return attrs
    }
    
    override var draftKey: String { "BasicEditorTextView.draftKey" }
    
    override var acceptedPostType: String {
        return "basic"
    }
    
    override var canContainAttachments: Bool {
        return false
    }
    
    // MARK: - Link
    func addLink(_ urlString: String, placeholder: String?) {
        let placeholder = placeholder ?? urlString
        var attrs = typingAttributes
        attrs[.link] = urlString
        let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
        textStorage.replaceCharacters(in: selectedRange, with: attrStr)
        let newSelectedRange = NSMakeRange(selectedRange.location + attrStr.length, 0)
        selectedRange = newSelectedRange
        typingAttributes = defaultTypingAttributes
    }
    
    override func getContentBlock(postTitle: String? = nil) -> Single<ResponseAPIContentBlock> {
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
                    type: "post",
                    attributes: ResponseAPIContentBlockAttributes(
                        title: postTitle,
                        type: self.acceptedPostType,
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
                block.maxId = id
                return block
        }
    }
}
