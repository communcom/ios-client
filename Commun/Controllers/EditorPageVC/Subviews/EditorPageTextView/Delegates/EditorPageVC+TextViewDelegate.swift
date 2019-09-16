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
            // Disable link effect after inputing a space or new line
            if text == "\n" || text == " " {
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
}
