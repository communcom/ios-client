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
        if textView == contentTextView {
            // Limit letters
            if contentTextView.text.count - range.length + text.count > contentLettersLimit {
                return false
            }
            
            return contentTextView.shouldChangeCharacterInRange(range, replacementText: text)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView == contentTextView {
            return contentTextView.shouldInteractWithTextAttachment(textAttachment, in: characterRange, interaction: interaction)
        }
        return true
    }
}
