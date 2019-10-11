//
//  ArticleEditorVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView == _contentTextView {
            return _contentTextView.shouldInteractWithTextAttachment(textAttachment, in: characterRange, interaction: interaction)
        }
        return true
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView {
            if text.contains("\n") {
                let text = text.replacingOccurrences(of: "\n", with: ".")
                let replacement = NSAttributedString(string: text, attributes: titleTextView.typingAttributes)
                let mutableAS = NSMutableAttributedString(attributedString: titleTextView.attributedText)
                mutableAS.replaceCharacters(in: range, with: replacement)
                titleTextView.attributedText = mutableAS
                titleTextView.selectedRange = NSMakeRange(range.location + replacement.length, 0)
                return false
            }
            return true
        }
        return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
    }
}
