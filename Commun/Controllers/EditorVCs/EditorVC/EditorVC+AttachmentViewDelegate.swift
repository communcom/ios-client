//
//  EditorVC+AttachmentViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC: AttachmentViewDelegate {
    @objc func attachmentViewExpandButtonDidTouch(_ attachmentView: AttachmentView) {
        guard let attachment = attachmentView.attachment else {return}
        previewAttachment(attachment)
    }
    
    @objc func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView) {
        fatalError("Must override")
    }
}
