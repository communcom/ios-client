//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 8/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func nsRangeOfText(_ text: String) -> NSRange {
        let str1 = string.nsString
        return str1.range(of: text)
    }
    
    func components(separatedBy string: String) -> [NSAttributedString] {
        let input = self.string
        let separatedInput = input.components(separatedBy: string)
        var output = [NSAttributedString]()
        var start = 0
        for sub in separatedInput {
            let range = NSMakeRange(start, sub.count)
            let attrStr = attributedSubstring(from: range)
            output.append(attrStr)
            start += range.length + string.count
        }
        return output
    }
    
    func toParagraphContentBlock(id: inout UInt) -> ContentBlock? {
        let originalId = id
        id += 1
        
        var blocks = [ContentBlock]()
        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attrs, range, bool) in
            var content = attributedSubstring(from: range).string.replacingOccurrences(of: "\u{200B}", with: "")
            var blockType = "text"
            
            // Parse links and tags
            if let url = attrs[.link] as? String {
                // links detector
                if !content.starts(with: "#") {
                    blockType = "link"
                    id += 1
                    let block = ContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ContentBlockAttributes(version: nil, title: nil, style: nil, text_color: nil, anchor: nil, url: url, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                        content: .string(content))
                    blocks.append(block)
                    return
                }
                
                // tags detector
                else {
                    blockType = "tag"
                    content = content.replacingOccurrences(of: "#", with: "")
                    id += 1
                    let block = ContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ContentBlockAttributes(version: nil, title: nil, style: nil, text_color: nil, anchor: url, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                        content: .string(content))
                    blocks.append(block)
                    return
                }
            }
            
            var text_color: String?
            if let color = attrs[.foregroundColor] as? UIColor {
                text_color = color.hexString
            }
            
            var style: [String]?
            if let font = attrs[.font] as? UIFont {
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    if style == nil {style = [String]()}
                    style?.append("bold")
                }
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    if style == nil {style = [String]()}
                    style?.append("italic")
                }
            }
            
            if !content.trimmed.isEmpty {
                id += 1
                let block = ContentBlock(
                    id: id,
                    type: blockType,
                    attributes: ContentBlockAttributes(version: nil, title: nil, style: style, text_color: text_color, anchor: nil, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                    content: .string(content))
                blocks.append(block)
            }
        }
        
        if !blocks.isEmpty {
            return ContentBlock(id: originalId + 1, type: "paragraph", attributes: nil, content: .array(blocks))
        } else {
            id = originalId
        }
        return nil
    }
}
