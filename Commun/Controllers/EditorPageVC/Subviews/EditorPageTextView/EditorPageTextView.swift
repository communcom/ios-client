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
import CyberSwift

class EditorPageTextView: ContentTextView {
    // MARK: - Constants
    let embedsLimit = 15
    let videosLimit = 10
    let draftKey = "EditorPageTextView.draftKey"
    
    // MARK: - Nested types
    struct TextStyle: Equatable {
        var isBold = false
        var isItalic = false
        // if format is unpersisted alongside selection
        var isMixed = false
        var textColor: UIColor = .black
        var urlString: String?
        
        static var `default`: TextStyle {
            return TextStyle(isBold: false, isItalic: false, isMixed: false, textColor: .black, urlString: nil)
        }
        
        /// Return new TextStyle by modifying current TextStyle
        func setting(isBool: Bool? = nil, isItalic: Bool? = nil, isMixed: Bool? = nil, textColor: UIColor? = nil, urlString: String? = nil) -> TextStyle
        {
            let isBool = isBool ?? self.isBold
            let isItalic = isItalic ?? self.isItalic
            let isMixed = isMixed ?? self.isMixed
            let textColor = textColor ?? self.textColor
            let urlString = urlString ?? self.urlString
            return TextStyle(isBold: isBool, isItalic: isItalic, isMixed: isMixed, textColor: textColor, urlString: urlString)
        }
    }
    
    // MARK: - Properties
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    var currentTextStyle = BehaviorRelay<TextStyle>(value: TextStyle(isBold: false, isItalic: false, isMixed: false, textColor: .black, urlString: nil))
    
    var originalAttributedString: NSAttributedString?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        // set default attributes
        defaultTypingAttributes = [.font: defaultFont]
        typingAttributes = defaultTypingAttributes
        
        super.awakeFromNib()
    }
    
    // MARK: - Computed properties
    var selectedAString: NSAttributedString {
        return attributedText.attributedSubstring(from: selectedRange)
    }
    
    override func bind() {
        super.bind()
        
        rx.didChangeSelection
            .subscribe(onNext: {
                // get TextStyle at current selectedRange
                self.setCurrentTextStyle()
            })
            .disposed(by: disposeBag)
    }
    
    override func clearFormatting() {
        if selectedRange.length == 0 {
            typingAttributes = defaultTypingAttributes
            setCurrentTextStyle()
        }
        else {
            textStorage.enumerateAttributes(in: selectedRange, options: []) {
                (attrs, range, stop) in
                if let link = attrs[.link] as? String {
                    if link.isLinkToTag || link.isLinkToMention {
                        return
                    }
                }
                textStorage.setAttributes(defaultTypingAttributes, range: range)
                currentTextStyle.accept(.default)
            }
        }
    }
}
