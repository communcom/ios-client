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
    
    func setBold(from sender: RichTextEditButton) {
        // default font
        var font = (selectedAString.attributes[.font] as? UIFont) ?? defaultFont
        let fontDescriptor = font.fontDescriptor
        var symbolicTraits = fontDescriptor.symbolicTraits
        
        // set bold
        if !sender.isSelected {
            symbolicTraits.insert(.traitBold)
        } else {
            symbolicTraits.remove(.traitBold)
        }
        
        font = UIFont(descriptor: fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: font.pointSize)
        
        if selectedRange.length > 0 {
            sender.isSelected = !sender.isSelected
        }
        
        addAttributeAtSelectedRange(.font, value: font)
    }
    
    func setItalic(from sender: RichTextEditButton) {
        // default font
        var font = (selectedAString.attributes[.font] as? UIFont) ?? defaultFont
        let fontDescriptor = font.fontDescriptor
        var symbolicTraits = fontDescriptor.symbolicTraits
        
        // set bold
        if !sender.isSelected {
            symbolicTraits.insert(.traitItalic)
        } else {
            symbolicTraits.remove(.traitItalic)
        }
        
        font = UIFont(descriptor: fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: font.pointSize)
        
        if selectedRange.length > 0 {
            sender.isSelected = !sender.isSelected
        }
        
        addAttributeAtSelectedRange(.font, value: font)
    }
    
    func setColor(_ color: UIColor, sender: UIButton) {
        addAttributeAtSelectedRange(.foregroundColor, value: color)
    }
    
    private func addAttributeAtSelectedRange(_ key: NSAttributedString.Key, value: Any) {
        var range = selectedRange
        if selectedRange.length == 0 {
            textStorage.insert(NSAttributedString(string: "\u{200B}"), at: selectedRange.location)
            range.length = 1
            textStorage.addAttribute(.font, value: defaultFont, range: range)
        }
        textStorage.addAttribute(key, value: value, range: range)
        if selectedRange.length == 0 {
            selectedRange = NSMakeRange(range.location + 1, 0)
        }
    }
}
