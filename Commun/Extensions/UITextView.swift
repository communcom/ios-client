//
//  UITextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UITextView {
    func addAttachment(_ attachment: NSTextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        let currentMAS = NSMutableAttributedString(attributedString: attributedText)
        currentMAS.insert(attachmentAS, at: selectedRange.location)
        currentMAS.addAttributes(typingAttributes, range: NSMakeRange(0, currentMAS.length))
        attributedText = currentMAS
    }
    
    func nsRangeOfText(_ text: String) -> NSRange {
        let str1 = attributedText.string.nsString
        return str1.range(of: text)
    }
    
    func rangeOfText(_ text: String) -> UITextRange? {
        let range = nsRangeOfText(text)
        
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length) else { return nil }
        
        return textRange(from: start, to: end)
    }
    
    func removeText(_ text: String) {
        guard let tRange = rangeOfText(text) else {return}
        replace(tRange, withText: "")
    }
}
