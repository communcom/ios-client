//
//  EditorPageTextView+Tools.swift
//  Commun
//
//  Created by Chung Tran on 9/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ContentTextView {
    // MARK: - Font
    @objc func toggleBold() {
        setSymbolicTrait(.traitBold, on: !currentTextStyle.value.isBold)
    }
    
    @objc func toggleItalic() {
        setSymbolicTrait(.traitItalic, on: !currentTextStyle.value.isItalic)
    }
    
    private func setSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits, on: Bool) {
        // Modify typingAttributes
        if selectedRange.length == 0 {
            var font = (typingAttributes[.font] as? UIFont) ?? (defaultTypingAttributes[.font] as! UIFont)
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
            // ignore link
            textStorage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, _) in
                if attrs[.link] != nil {
                    return
                }
                var font = (attrs[.font] as? UIFont) ?? (defaultTypingAttributes[.font] as! UIFont)
                let fontDescriptor = font.fontDescriptor
                var symbolicTraits = fontDescriptor.symbolicTraits
                
                if on {
                    symbolicTraits.insert(trait)
                } else {
                    symbolicTraits.remove(trait)
                }
                
                font = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: font.pointSize)
                textStorage.addAttribute(.font, value: font, range: range)
            }
        }
        
        if trait.contains(.traitBold) {
            currentTextStyle.accept(
                currentTextStyle.value.setting(isBool: on)
            )
        } else if trait.contains(.traitItalic) {
            currentTextStyle.accept(
                currentTextStyle.value.setting(isItalic: on)
            )
        }
    }
    
    // MARK: - Text color
    func setColor(_ color: UIColor) {
        if selectedRange.length == 0 {
            typingAttributes[.foregroundColor] = color
        } else {
            textStorage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, _) in
                if attrs[.link] != nil {return}
                textStorage.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        
        currentTextStyle.accept(
            currentTextStyle.value.setting(textColor: color)
        )
    }
}
