//
//  ContentTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CyberSwift

class ContentTextView: UITextView {
    // MARK: - Nested types
    enum CTVError: Error {
        case parsingError(message: String)
        var localizedDescription: String {
            switch self {
            case .parsingError(let message):
                return message
            }
        }
    }
    
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
    // Must override!!!
    var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        fatalError("Must override")
    }
    
    var acceptedPostType: String {
        fatalError("Must override")
    }
    
    var draftKey: String {
        fatalError("Must override")
    }
    
    var canContainAttachments: Bool {
        fatalError("Must override")
    }
    
    let disposeBag = DisposeBag()
    var originalAttributedString: NSAttributedString?
    
    var currentTextStyle = BehaviorRelay<TextStyle>(value: TextStyle(isBold: false, isItalic: false, isMixed: false, textColor: .black, urlString: nil))
    
    // MARK: - Class Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    func commonInit() {
        isScrollEnabled = false
        typingAttributes = defaultTypingAttributes
        textContainer.lineFragmentPadding = 0
        bind()
    }
    
    func bind() {
        rx.didChange
            .subscribe(onNext: {
                self.resolveMentions()
                self.resolveHashTags()
                self.resolveLinks()
                
                // reset
                if self.attributedText.length == 0 {
                    self.clearFormatting()
                }
            })
            .disposed(by: disposeBag)
        
        rx.didChangeSelection
            .subscribe(onNext: {
                // get TextStyle at current selectedRange
                self.setCurrentTextStyle()
            })
            .disposed(by: disposeBag)
    }
    
    func clearFormatting() {
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
            }
            currentTextStyle.accept(.default)
        }
    }
    
    func shouldChangeCharacterInRange(_ range: NSRange, replacementText text: String) -> Bool
    {
        // Disable link effect after non-allowed-in-name character
        // Check if text is not a part of tag or mention
        let regex = "^" + String(NSRegularExpression.nameRegexPattern.dropLast()) + "$"
        if !text.matches(regex) {
            // if appended
            if range.length == 0 {
                // get range of last character
                let lastLocation = range.location - 1
                if lastLocation < 0 {
                    return true
                }
                // get last link attribute
                let attr = textStorage.attributes(at: lastLocation, effectiveRange: nil)
                if attr.has(key: .link) {
                    typingAttributes = defaultTypingAttributes
                }
            }
            // if inserted
        }
        
        // Remove link
        if text == "", range.length > 0, range.location > 0
        {
            removeLink()
        }
        
        return true
    }
    
    func removeLink() {
        if selectedRange.length > 0 {
            textStorage.removeAttribute(.link, range: selectedRange)
        }
            
        else if selectedRange.length == 0 {
            let attr = typingAttributes
            if let link = attr[.link] as? String,
                link.isLink
            {
                textStorage.enumerateAttribute(.link, in: NSMakeRange(0, textStorage.length), options: []) { (currentLink, range, stop) in
                    if currentLink as? String == link,
                        range.contains(selectedRange.location - 1)
                    {
                        textStorage.removeAttribute(.link, range: range)
                    }
                }
            }
        }
    }
    
    func insertTextWithDefaultAttributes(_ text: String, at index: Int) {
        textStorage.insert(NSAttributedString(string: text, attributes: defaultTypingAttributes), at: index)
    }
    
    // MARK: - Draft
    
    
    /// For parsing attachments only, if attachments are not allowed, leave an empty Completable
    func parseAttachments() -> Completable {
        return .empty()
    }
    
    // MARK: - ContentBlock
    func getContentBlock(postTitle: String? = nil) -> Single<ResponseAPIContentBlock> {
        fatalError("Must override")
    }
}
 
