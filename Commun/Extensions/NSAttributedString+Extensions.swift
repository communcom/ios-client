//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 8/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

extension NSAttributedString {
    func nsRangeOfText(_ text: String) -> NSRange {
        let str1 = string.nsString
        return str1.range(of: text)
    }
    
    func replaceOccurents(of stringToReplace: String, with newStringPart: String) -> NSMutableAttributedString
    {
        let mutableAttributedString = mutableCopy() as! NSMutableAttributedString
        let mutableString = mutableAttributedString.mutableString
        while mutableString.contains(stringToReplace) {
            let rangeOfStringToBeReplaced = mutableString.range(of: stringToReplace)
            mutableAttributedString.replaceCharacters(in: rangeOfStringToBeReplaced, with: newStringPart)
        }
        return mutableAttributedString
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
    
    func toParagraphContentBlock(id: inout UInt64) -> ResponseAPIContentBlock? {
        let originalId = id
        id += 1
        
        var blocks = [ResponseAPIContentBlock]()
        enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { (attrs, range, _) in
            // get text
            var content = attributedSubstring(from: range).string
            if content.isEmpty { return }
            
            var blockType = "text"
            
            // Parse links and tags
            if let url = attrs[.link] as? String {
                // tags detector
                if content.starts(with: "#") {
                    blockType = "tag"
                    content = content.replacingOccurrences(of: "#", with: "")
                    id += 1
                    let block = ResponseAPIContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ResponseAPIContentBlockAttributes(),
                        content: .string(content))
                    blocks.append(block)
                }
                    
                // mention detector
                else if content.starts(with: "@") {
                    blockType = "mention"
                    content = content.replacingOccurrences(of: "@", with: "")
                    id += 1
                    let block = ResponseAPIContentBlock(
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
                    let block = ResponseAPIContentBlock(
                        id: id,
                        type: blockType,
                        attributes: ResponseAPIContentBlockAttributes(url: url),
                        content: .string(content))
                    blocks.append(block)
                }
                
                return
            }
            
            var textColor: String?
            if let color = attrs[.foregroundColor] as? UIColor {
                let hexString = color.hexString
                if hexString != "#000000" {
                    textColor = hexString
                }
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
            
            // add block if content is not empty
            id += 1
            
            var attributes: ResponseAPIContentBlockAttributes?
            
            if style != nil || textColor != nil {
                attributes = ResponseAPIContentBlockAttributes(style: style, textColor: textColor)
            }
            
            let block = ResponseAPIContentBlock(
                id: id,
                type: blockType,
                attributes: attributes,
                content: .string(content))
            blocks.append(block)
        }
        
        if !blocks.isEmpty {
            return ResponseAPIContentBlock(id: originalId + 1, type: "paragraph", attributes: nil, content: .array(blocks))
        } else {
            id = originalId
        }
        return nil
    }
    
    static var separator: NSAttributedString {
        // \u2063 means Invisible Separator
        let separator = NSMutableAttributedString(string: "\n")
        return separator
    }
    
    func heightWithWidth(width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = self
        label.sizeToFit()
        return label.frame.height
    }
}
