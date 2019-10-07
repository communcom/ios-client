//
//  EditorVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == contentTextView {
            return contentTextView.shouldChangeCharacterInRange(range, replacementText: text)
        }
        return true
    }
}
