//
//  ContentTextView+Utilities.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
extension ContentTextView {
    // MARK: - typingAttributes modification
    func setCurrentTextStyle() {
        var textStyle = TextStyle.default
        
        // Get attributes from typingAttributes
        let attrs = typingAttributes
        
        if let font = attrs[.font] as? UIFont {
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                textStyle = textStyle.setting(isBool: true)
            }
            
            if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                textStyle = textStyle.setting(isItalic: true)
            }
        }

//        textStyle = textStyle.setting(textColor: text.isEmpty ? #colorLiteral(red: 0.647, green: 0.655, blue: 0.741, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        if let color = attrs[.foregroundColor] as? UIColor, color != .appBlackColor {
            textStyle = textStyle.setting(textColor: color)
        }
        
        if let link = attrs[.link] as? String {
            textStyle = textStyle.setting(textColor: .link, urlString: link)
        }
        
        // Check if textStyle is mixed
        textStyle = textStyle.setting(isMixed: selectedRangeHasDifferentTextStyle)
        
        // Notify
        self.currentTextStyle.accept(textStyle)
    }
    
    /// if text in selectedRange has different style
    var selectedRangeHasDifferentTextStyle: Bool {
        if selectedRange.length == 0 { return false }
        var isMixed = false
        textStorage.enumerateAttributes(in: selectedRange, options: []) { (_, range, stop) in
            if range != selectedRange {
                isMixed = true
                stop.pointee = true
            }
        }
        return isMixed
    }
}
