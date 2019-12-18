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
            return contentTextView.shouldChangeCharacterInRange(range, replacementText: text)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
}
