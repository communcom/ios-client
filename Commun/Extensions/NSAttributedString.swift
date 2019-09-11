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
    
    func components(separatedBy separator: String) -> [NSAttributedString] {
        var result = [NSAttributedString]()
        let separatedStrings = string.components(separatedBy: separator)
        var range = NSRange(location: 0, length: 0)
        for string in separatedStrings {
            range.length = string.utf16.count
            let attributedString = attributedSubstring(from: range)
            result.append(attributedString)
            range.location += range.length + separator.utf16.count
        }
        return result
    }
    
    func toParagraphContentBlock(id: inout UInt) -> ContentBlock? {
        let originalId = id
        id += 1
        
        var blocks = [ContentBlock]()
        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attrs, range, bool) in
            var content = attributedSubstring(from: range).string
            var blockType = "text"
            
            // Parse links and tags
            if let url = attrs[.link] as? String {
                // tags detector
                if content.starts(with: "#") {
                    blockType = "tag"
                    content = content.replacingOccurrences(of: "#", with: "")
                    id += 1
                    let block = ContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ContentBlockAttributes(),
                        content: .string(content))
                    blocks.append(block)
                }
                    
                // mention detector
                else if content.starts(with: "@") {
                    blockType = "mention"
                    content = content.replacingOccurrences(of: "@", with: "")
                    id += 1
                    let block = ContentBlock(
                        id: id,
                        type: blockType,
                        attributes: nil,
                        content: .string(content)
                    )
                    blocks.append(block)
                }
                
                // tags detector
                else {
                    blockType = "link"
                    id += 1
                    let block = ContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ContentBlockAttributes(url: url),
                        content: .string(content))
                    blocks.append(block)
                }
                
                return
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
            
            // modify content
            // remove invisible character
            content = content.replacingOccurrences(of: String.invisible, with: "")
            
            // add block if content is not empty
            id += 1
            let block = ContentBlock(
                id: id,
                type: blockType,
                attributes: ContentBlockAttributes(style: style, text_color: text_color),
                content: .string(content))
            blocks.append(block)
        }
        
        if !blocks.isEmpty {
            return ContentBlock(id: originalId + 1, type: "paragraph", attributes: nil, content: .array(blocks))
        } else {
            id = originalId
        }
        return nil
    }
    
    /// find range of text which has the same attributes as text at index
    func rangeOfLink(at index: Int) -> NSRange? {
        if index >= length {return nil}
        let attrs = attributes(at: index, effectiveRange: nil)
        
        guard let urlString = attrs[.link] as? String else {return nil}
        
        // the start and the end of the length
        var start = index
        var end = index
        
        // move backward
        for i in (0..<index).reversed() {
            // Compare attributes
            if attributes(at: i, effectiveRange: nil)[.link] as? String == urlString {
                start = i
            } else {
                break
            }
        }
        
        // move forward
        for i in ((index + 1)...length-1) {
            // Compare attributes
            if attributes(at: i, effectiveRange: nil)[.link] as? String == urlString {
                end = i
            } else {
                break
            }
        }
        
        return NSMakeRange(start, end - start + 1)
    }
}
