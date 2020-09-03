//
//  ArticleEditorVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView == _contentTextView {
            return _contentTextView.shouldInteractWithTextAttachment(textAttachment, in: characterRange, interaction: interaction)
        }
        return true
    }
}
