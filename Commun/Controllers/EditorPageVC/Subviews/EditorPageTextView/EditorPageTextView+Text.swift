//
//  EditorPageTextView+Tools.swift
//  Commun
//
//  Created by Chung Tran on 9/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageTextView {
    // MARK: - Font
    func setBold(from sender: UIButton) {
        setSymbolicTrait(.traitBold, on: !sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    func setItalic(from sender: UIButton) {
        setSymbolicTrait(.traitItalic, on: !sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    private func setSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits, on: Bool) {
        // Modify typingAttributes
        if selectedRange.length == 0 {
            var font = (typingAttributes[.font] as? UIFont) ?? defaultFont
            var symbolicTraits = font.fontDescriptor.symbolicTraits
            
            if on {
                symbolicTraits.insert(trait)
            } else {
                symbolicTraits.remove(trait)
            }
            
            font = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: font.pointSize)
            typingAttributes[.font] = font
        }
            // Modify selectedText's attributes
        else {
            // default font
            var font = (selectedAString.attributes[.font] as? UIFont) ?? defaultFont
            let fontDescriptor = font.fontDescriptor
            var symbolicTraits = fontDescriptor.symbolicTraits
            
            if on {
                symbolicTraits.insert(trait)
            } else {
                symbolicTraits.remove(trait)
            }
            
            font = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: font.pointSize)
            textStorage.addAttribute(.font, value: font, range: selectedRange)
        }
    }
    
    // MARK: - Text color
    func setColor(_ color: UIColor, sender: UIButton) {
        if selectedRange.length == 0 {
            typingAttributes[.foregroundColor] = color
        } else {
            textStorage.addAttribute(.foregroundColor, value: color, range: selectedRange)
        }
    }
    
    // MARK: - Hashtags
    func resolveHashTags() {
        if let regex = try? NSRegularExpression(pattern: String.tagRegex, options: .caseInsensitive)
        {
            let currentSelected = selectedRange
            let string = text as NSString
            
            _ = regex.matches(in: text, options: [], range: NSRange(location: 0, length: string.length)).compactMap { match -> String in
                
                let tag = string.substring(with: match.range)
                
                let newAttr = NSMutableAttributedString(attributedString: self.attributedText)
                newAttr.addAttribute(.link, value: "https://commun.com/\(tag)", range: match.range)
                self.attributedText = newAttr
                self.selectedRange = currentSelected
                return tag
            }
        }
    }
    
    // MARK: - Mentions
    func resolveMentions() {
        if let regex = try? NSRegularExpression(pattern: String.mentionRegex, options: .caseInsensitive)
        {
            let currentSelected = selectedRange
            let string = text as NSString
            
            _ = regex.matches(in: text, options: [], range: NSRange(location: 0, length: string.length)).compactMap { match -> String in
                
                let mention = string.substring(with: match.range)
                
                let newAttr = NSMutableAttributedString(attributedString: self.attributedText)
                newAttr.addAttribute(.link, value: "https://commun.com/\(mention)", range: match.range)
                self.attributedText = newAttr
                self.selectedRange = currentSelected
                return mention
            }
        }
    }
}
