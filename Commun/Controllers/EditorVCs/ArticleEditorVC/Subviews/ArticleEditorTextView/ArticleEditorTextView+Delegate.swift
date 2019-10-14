//
//  EditorPageTextView+Delegate.swift
//  Commun
//
//  Created by Chung Tran on 9/20/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorTextView {
    func shouldInteractWithTextAttachment(_ textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
    func copyAttachment(_ attachment: TextAttachment, completion: (()->Void)? = nil) {
        parentViewController?.showIndetermineHudWithMessage(
            "archiving".localized().uppercaseFirst)
        
        DispatchQueue(label: "archiving").async {
            if let data = try? JSONEncoder().encode(attachment) {
                UIPasteboard.general.setData(data, forPasteboardType: "attachment")
            }
            DispatchQueue.main.sync {
                self.parentViewController?.hideHud()
                completion?()
            }
        }
    }
    
    func removeAttachment(at location: inout Int) {
        let range = NSRange(location: location, length: 1)
        
        var isAttachment = false
        textStorage.enumerateAttribute(.attachment, in: range, options: []) { (att, range, stop) in
            if let attachment = att as? TextAttachment {
                attachment.attachmentView?.removeFromSuperview()
                isAttachment = true
            }
            stop.pointee = true
        }
        
        if !isAttachment {return}
        
        // Remove "\n" before attachment
        if location > 0,
            self.textStorage.attributedSubstring(from: NSMakeRange(location - 1, 1)).string == "\n"
        {
            self.textStorage.replaceCharacters(in: NSMakeRange(self.selectedRange.location - 1, 1), with: "")
            location -= 1
        }
        
        self.textStorage.replaceCharacters(in: NSMakeRange(location, 1), with: "")
        
        // Remove "\n" after attachment
        if location < self.textStorage.length,
            self.textStorage.attributedSubstring(from: NSMakeRange(location, 1)).string == "\n"
        {
            self.textStorage.replaceCharacters(in: NSMakeRange(location, 1), with: "")
        }
    }
}
