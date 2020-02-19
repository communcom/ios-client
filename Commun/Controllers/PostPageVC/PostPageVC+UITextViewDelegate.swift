//
//  PostPageVC+UITextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 2/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension PostPageVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == commentForm.textView {
            return commentForm.textView.shouldChangeCharacterInRange(range, replacementText: text)
        }
        return true
    }
}
