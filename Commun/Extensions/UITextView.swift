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
    
    func addImage(_ image: UIImage, description: String? = nil) {
        let textAttachment = TextAttachment()
        // set image
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width
        let scaleFactor = oldWidth / (frame.size.width - 10)
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        // set description
        textAttachment.descriptionText = description
        
        addAttachment(textAttachment)
    }
}
