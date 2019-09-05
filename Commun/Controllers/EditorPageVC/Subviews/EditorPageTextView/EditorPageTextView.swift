//
//  EditorPageTextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import CyberSwift

class EditorPageTextView: ExpandableTextView {
    // MARK: - Nested types
    struct TextStyle {
        var isBold = false
        var isItalic = false
        var textColor: UIColor = .black
        var urlString: String?
    }
    
    // MARK: - Properties
    let bag = DisposeBag()
    let defaultFont = UIFont.systemFont(ofSize: 17)
    var currentTextStyle = BehaviorRelay<TextStyle>(value: TextStyle(isBold: false, isItalic: false, textColor: .black, urlString: nil))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // set default attributes
        typingAttributes = [.font: defaultFont]
        
        // bind actions
        bind()
    }
    
    var selectedAString: NSAttributedString {
        return attributedText.attributedSubstring(from: selectedRange)
    }
    
    func setBold(from sender: UIButton) {
        setSymbolicTrait(.traitBold, on: !sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    func setItalic(from sender: UIButton) {
        setSymbolicTrait(.traitItalic, on: !sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    func setColor(_ color: UIColor, sender: UIButton) {
        if selectedRange.length == 0 {
            typingAttributes[.foregroundColor] = color
        } else {
            textStorage.addAttribute(.foregroundColor, value: color, range: selectedRange)
        }
    }
    
    func addLink(_ urlString: String, placeholder: String) {
        var attrs = typingAttributes
        attrs[.link] = urlString
        let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
        attrStr.insert(NSAttributedString(string: "\u{2063}", attributes: typingAttributes), at: 0)
        attrStr.append(NSAttributedString(string: "\u{2063}", attributes: typingAttributes))
        textStorage.replaceCharacters(in: selectedRange, with: attrStr)
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
}
