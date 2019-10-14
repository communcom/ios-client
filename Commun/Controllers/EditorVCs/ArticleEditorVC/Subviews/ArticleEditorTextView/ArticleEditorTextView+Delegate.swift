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
}
