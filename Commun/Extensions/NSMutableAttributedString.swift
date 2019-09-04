//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SwiftLinkPreview
import RxSwift
import CyberSwift

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .bold), color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string:text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }
    
    @discardableResult func semibold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold), color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string:text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func gray(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs).colored(with: UIColor.gray)
        append(normal)
        return self
    }
    
    @discardableResult func underline(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .underlineStyle: NSUnderlineStyle.single]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
    
    func toContentBlock() -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ContentBlock>]()
        
        // get AS, which was separated by the Escaping String
        var currentParagraph: NSMutableAttributedString?
        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attrs, range, bool) in
            // parse attachments
            if let attachment = attrs[.attachment] as? TextAttachment {
                if let paragraph = currentParagraph,
                    let block = paragraph.toParagraphContentBlock(id: &id){
                    contentBlocks.append(.just(block))
                    currentParagraph = nil
                }
                if let single = attachment.toSingleContentBlock(id: &id) {
                    contentBlocks.append(single)
                }
            }
            
            else {
                if currentParagraph == nil {
                    currentParagraph = NSMutableAttributedString()
                }
                currentParagraph?.append(attributedSubstring(from: range))
            }
        }
        
        // apend last currentParagraph
        if let paragraph = currentParagraph,
            let block = paragraph.toParagraphContentBlock(id: &id){
            contentBlocks.append(.just(block))
            currentParagraph = nil
        }

        return Single.zip(contentBlocks)
            .map {contentBlocks -> ContentBlock in
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(version: 1, title: nil, style: nil, text_color: nil, anchor: nil, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                    content: .array(contentBlocks))
            }
    }
}
