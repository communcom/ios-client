//
//  PostHeaderView+UITextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        parentViewController?.handleUrl(url: URL)
        return false
    }
}
