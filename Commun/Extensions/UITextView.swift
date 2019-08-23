//
//  UITextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UITextView {
    func addAttachment(_ attachment: NSTextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        let currentMAS = NSMutableAttributedString(attributedString: attributedText)
        currentMAS.insert(attachmentAS, at: selectedRange.location)
        currentMAS.addAttributes(typingAttributes, range: NSMakeRange(0, currentMAS.length))
        attributedText = currentMAS
    }
}
