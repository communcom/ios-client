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
        
        sender.isSelected = !sender.isSelected
        textStorage.addAttribute(.font, value: font, range: selectedRange)
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
        
        sender.isSelected = !sender.isSelected
        textStorage.addAttribute(.font, value: font, range: selectedRange)
    }
    
    func setColor(_ color: UIColor, sender: UIButton) {
        textStorage.addAttribute(.foregroundColor, value: color, range: selectedRange)
    }
}
