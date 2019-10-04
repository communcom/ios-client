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

class ContentTextView: ExpandableTextView {
    // MARK: - Properties
    // Must override!!!
    var defaultTypingAttributes: [NSAttributedString.Key: Any]!
    let disposeBag = DisposeBag()
    var originalAttributedString: NSAttributedString?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    }
    
    func clearFormatting() {
        // for overriding
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
}
 
