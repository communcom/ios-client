//
//  EditorPageVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 9/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textView = textView as? EditorPageTextView {
            // Limit letters
            if textView.text.count - range.length + text.count > contentLettersLimit {
                return false
            }
            
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
                    let attr = textView.textStorage.attributes(at: lastLocation, effectiveRange: nil)
                    if attr.has(key: .link) {
                        textView.typingAttributes = textView.defaultTypingAttributes
                    }
                }
                // if inserted
                
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let attachment = textAttachment as? TextAttachment {
            showActionSheet(title: "choose action".localized().uppercaseFirst, message: nil, actions: [
                    UIAlertAction(title: "copy".localized().uppercaseFirst, style: .default, handler: { (_) in
                        UIPasteboard.general
                            .setData(
                                NSKeyedArchiver.archivedData(withRootObject: attachment), forPasteboardType: "attachment")
                    }),
                    UIAlertAction(title: "cut".localized().uppercaseFirst, style: .default, handler: { (_) in
                        self.contentTextView.textStorage.replaceCharacters(in: characterRange, with: "")
                        UIPasteboard.general
                            .setData(
                                NSKeyedArchiver.archivedData(withRootObject: attachment), forPasteboardType: "attachment")
                    })
                ])
            
            return false
        }
        return true
    }
}
