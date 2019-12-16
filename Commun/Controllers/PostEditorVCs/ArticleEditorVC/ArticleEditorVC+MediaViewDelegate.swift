//
//  ArticleEditorVC+MediaViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    override func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView) {
        guard let attachment = attachmentView.attachment else {return}
        
        _contentTextView.textStorage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: _contentTextView.textStorage.length), options: []) { (att, range, stop) in
            if let att = att as? TextAttachment,
                att.id == attachment.id {
                _contentTextView.textStorage.replaceCharacters(in: range, with: "")
                attachment.attachmentView?.removeFromSuperview()
                stop.pointee = true
            }
        }
    }
}
