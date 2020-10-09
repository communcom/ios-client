//
//  EditorPageTextView+Utilities.swift
//  Commun
//
//  Created by Chung Tran on 9/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ArticleEditorTextView {
    // MARK: - Attachment helper    
    func canAddAttachment(_ attachment: TextAttachment) -> Bool {
        var embedCount = 1
        var videoCount = attachment.attributes?.type == "video" ? 1 : 0
        
        // Count attachments
        textStorage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: textStorage.length), options: []) { (attr, _, _) in
            if let attr = attr as? TextAttachment {
                embedCount += 1
                if attr.attributes?.type == "video" {
                    videoCount += 1
                }
            }
        }
        
        return embedCount <= embedsLimit && videoCount <= videosLimit
    }
    
    func addAttachmentAtSelectedRange(_ attachment: TextAttachment) {
        // check if can add attachment
        if !canAddAttachment(attachment) {
            parentViewController?.showErrorWithMessage("can not add more than".localized().uppercaseFirst + " " + "\(embedsLimit)" + " " + "attachments".localized() + " " + "and" + " " + "\(videosLimit)" + " " + "videos".localized())
            return
        }
        
        // attachmentAS to add
        let attachmentAS = NSMutableAttributedString()
        
        // insert an separator at the beggining of attachment if not exists
        if selectedRange.location > 0,
            textStorage.attributedSubstring(from: NSRange(location: selectedRange.location - 1, length: 1)).string != "\n" {
            attachmentAS.append(NSAttributedString.separator)
        }
        
        attachmentAS.append(NSAttributedString(attachment: attachment))
        attachmentAS.append(NSAttributedString.separator)
        attachmentAS.addAttributes(typingAttributes, range: NSRange(location: 0, length: attachmentAS.length))
        
        // replace
        textStorage.replaceCharacters(in: selectedRange, with: attachmentAS)
        selectedRange = NSRange(location: selectedRange.location + attachmentAS.length, length: 0)
    }
    
    func replaceCharacters(in range: NSRange, with attachment: TextAttachment) {
        let attachment = TextAttachment(attributes: attachment.attributes, localImage: attachment.localImage, size: attachmentSize)
        attachment.delegate = parentViewController as? AttachmentViewDelegate
        let attachmentAS = NSAttributedString(attachment: attachment)
        textStorage.replaceCharacters(in: range, with: attachmentAS)
        textStorage.addAttributes(typingAttributes, range: NSRange(location: range.location, length: 1))
    }
    
    // MARK: - contextMenu modification
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // if selected attachment
        if selectedAttachment != nil {
            if action == #selector(copy(_:)) || action == #selector(cut(_:)) {
                return true
            }
        }
        
        if action == #selector(paste(_:)) {
            let pasteBoard = UIPasteboard.general
            if pasteBoard.items.last?["attachment"] != nil { return true }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func copy(_ sender: Any?) {
        if let attachment = selectedAttachment {
            copyAttachment(attachment)
            return
        }
        return super.copy(sender)
    }

    override func cut(_ sender: Any?) {
        if let attachment = selectedAttachment {
            self.copyAttachment(attachment, completion: {
                var location = self.selectedRange.location
                self.removeAttachment(at: &location)
                
                // Resign selection
                self.selectedRange = NSRange(location: location, length: 0)
            })
            return
        }
        return super.cut(sender)
    }
    
    override func paste(_ sender: Any?) {
        let pasteBoard = UIPasteboard.general
        
        // Paste attachment
        if let data = pasteBoard.items.last?["attachment"] as? Data,
            let attachment = try? JSONDecoder().decode(TextAttachment.self, from: data) {
            attachment.delegate = self.parentViewController as? AttachmentViewDelegate
            addAttachmentAtSelectedRange(attachment)
            return
        }

        super.paste(sender)
    }
}
