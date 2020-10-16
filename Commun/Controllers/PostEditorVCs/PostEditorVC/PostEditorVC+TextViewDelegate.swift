//
//  PostEditorVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostEditorVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView {
            if text.contains("\n") {
                let text = text.replacingOccurrences(of: "\n", with: ".")
                let replacement = NSAttributedString(string: text, attributes: titleTextView.typingAttributes)
                let mutableAS = NSMutableAttributedString(attributedString: titleTextView.attributedText)
                mutableAS.replaceCharacters(in: range, with: replacement)
                titleTextView.attributedText = mutableAS
                titleTextView.selectedRange = NSRange(location: range.location + replacement.length, length: 0)
                return false
            }
            return true
        }
        if textView == contentTextView {
            let shouldChange = contentTextView.shouldChangeCharacterInRange(range, replacementText: text)
            if shouldChange {
                DispatchQueue(label: "archiving").async {
                    self.saveDraft()
                }
                showExplanationViewIfNeeded()
            }
            return shouldChange
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
}
