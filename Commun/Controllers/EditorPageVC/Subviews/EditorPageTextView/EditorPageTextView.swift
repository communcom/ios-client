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
    var currentTextStyle = PublishSubject<TextStyle>()
    
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
