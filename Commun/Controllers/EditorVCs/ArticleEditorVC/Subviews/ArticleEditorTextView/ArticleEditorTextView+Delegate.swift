//
//  EditorPageTextView+Delegate.swift
//  Commun
//
//  Created by Chung Tran on 9/20/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SafariServices
import AppImageViewer

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
    
    @objc func previewAttachment(_ sender: Any?) {
        guard let sender = sender as? UIMenuController,
            let item = sender.menuItems?.first(where: {$0 is AttachmentMenuItem}) as? AttachmentMenuItem
        else {return}
        
        let attachment = item.attachment
        guard let type = attachment.embed?.type else {return}

        switch type {
        case "website", "video":
            guard let urlString = attachment.embed?.url,
                let url = URL(string: urlString) else {return}
            let safariVC = SFSafariViewController(url: url)
            self.parentViewController?.present(safariVC, animated: true, completion: nil)
        case "image":
            if let localImage = attachment.localImage {
                let appImage = ViewerImage.appImage(forImage: localImage)
                let viewer = AppImageViewer(photos: [appImage])
                self.parentViewController?.present(viewer, animated: false, completion: nil)
            }
            else if let imageUrl = attachment.embed?.url,
                let url = URL(string: imageUrl)
            {
                NetworkService.shared.downloadImage(url)
                    .subscribe(onSuccess: { [weak self] (image) in
                        let appImage = ViewerImage.appImage(forImage: image)
                        let viewer = AppImageViewer(photos: [appImage])
                        self?.parentViewController?.present(viewer, animated: false, completion: nil)
                        }, onError: { (error) in
                            self.parentViewController?.showError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
        default:
            break
        }
    }
}
