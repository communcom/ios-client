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
        if textView == contentTextView {
            let shouldChange = contentTextView.shouldChangeCharacterInRange(range, replacementText: text)
            if shouldChange {
                DispatchQueue(label: "archiving").async {
                    self.saveDraft()
                }
                if textView.text.isEmpty {
                    showExplanationView()
                }
            }
            return shouldChange
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
}
