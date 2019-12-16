//
//  UITextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UITextView {
    var selectedAString: NSAttributedString {
        return attributedText.attributedSubstring(from: selectedRange)
    }
    
    func addAttachment(_ attachment: NSTextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        let currentMAS = NSMutableAttributedString(attributedString: attributedText)
        currentMAS.insert(attachmentAS, at: selectedRange.location)
        currentMAS.addAttributes(typingAttributes, range: NSMakeRange(0, currentMAS.length))
        attributedText = currentMAS
    }
    
    func rangeOfText(_ text: String) -> UITextRange? {
        let range = attributedText.nsRangeOfText(text)
        
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length) else { return nil }
        
        return textRange(from: start, to: end)
    }
    
    func removeText(_ text: String) {
        guard let tRange = rangeOfText(text) else {return}
        textStorage.beginEditing()
        replace(tRange, withText: "")
        textStorage.endEditing()
    }
    
    var currentCursorLocation: Int? {
        if let selectedRange = self.selectedTextRange {
            let cursorPosition = offset(from: beginningOfDocument, to: selectedRange.start)
            return cursorPosition
        }
        return nil
    }
    
    // MARK: - Hashtags
    func resolveHashTags() {
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.tagRegexPattern, options: .caseInsensitive)
        {
            addAppLink(regex: regex, prefix: "\(URL.appURL)/")
        }
    }
    
    // MARK: - Mentions
    func resolveMentions() {
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.mentionRegexPattern, options: .caseInsensitive)
        {
            addAppLink(regex: regex, prefix: "\(URL.appURL)/")
        }
    }
    
    // MARK: - Link detector
    func resolveLinks() {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            let url = text[range]
            textStorage.addAttributes([.link: url], range: match.range)
        }
    }
    
    private func addAppLink(regex: NSRegularExpression, prefix: String? = nil) {
        let currentSelected = selectedRange
        let matches = regex.matchedStrings(in: text)
        for match in matches {
            let range = textStorage.nsRangeOfText(match)
            let newAttr = NSMutableAttributedString(attributedString: self.attributedText)
            newAttr.addAttribute(.link, value: "\(prefix ?? "")\(match)", range: range)
            self.attributedText = newAttr
            self.selectedRange = currentSelected
        }
    }
}
