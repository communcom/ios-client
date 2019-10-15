//
//  AttachmentsView.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class AttachmentsView: UIView {
    var imageViews: [UIImageView]?
    var didRemoveAttachmentAtIndex: ((Int)->Void)?
    
    @objc func close(sender: UIButton) {
        let index = sender.tag
        didRemoveAttachmentAtIndex?(index)
    }
    
    func setUp(with attachments: [TextAttachment]) {
        removeSubviews()
        
        let gridView = GridView(forAutoLayout: ())
        addSubview(gridView)
        gridView.autoPinEdgesToSuperviewEdges()
        
        var attachmentViews = [AttachmentView]()
        
        if attachments.count == 1,
            attachments[0].embed?.type == "website" || attachments[0].embed?.type == "video"
        {
            let attachmentView = AttachmentView(forAutoLayout: ())
            attachmentView.attachment = attachments[0]
            attachmentView.isUserInteractionEnabled = true
            attachmentView.tag = 0
            attachmentView.delegate = self
            
            attachmentView.setUp(image: attachments[0].localImage, url: attachments[0].embed?.url, description: attachments[0].embed?.title ?? attachments[0].embed?.description)
            
            attachmentViews.append(attachmentView)
        }
        else {
            for (index, attachment) in attachments.enumerated() {
                let attachmentView = AttachmentView(forAutoLayout: ())
                attachmentView.attachment = attachment
                attachmentView.isUserInteractionEnabled = true
                attachmentView.tag = index
                attachmentView.delegate = self
                
                if let image = attachment.localImage {
                    attachmentView.setUp(image: image)
                }
                attachmentViews.append(attachmentView)
            }
        }
        gridView.setUp(views: attachmentViews)
    }
}

extension AttachmentsView: AttachmentViewDelegate {
    func attachmentViewExpandButtonDidTouch(_ attachmentView: AttachmentView) {
        guard let vc = parentViewController as? BasicEditorVC else {return}
        vc.attachmentViewExpandButtonDidTouch(attachmentView)
    }
    
    func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView) {
        didRemoveAttachmentAtIndex?(attachmentView.tag)
    }
}
