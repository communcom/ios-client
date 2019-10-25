//
//  CommentForm+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommentForm: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textView = self.textView!
        return textView.shouldChangeCharacterInRange(range, replacementText: text)
    }
}
