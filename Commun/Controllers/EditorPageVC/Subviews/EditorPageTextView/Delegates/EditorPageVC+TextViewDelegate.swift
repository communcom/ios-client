//
//  EditorPageVC+TextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 9/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SafariServices
import AppImageViewer

extension EditorPageVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textView = textView as? EditorPageTextView {
            // Limit letters
            if textView.text.count - range.length + text.count > contentLettersLimit {
                return false
            }
            
            // Disable link effect after non-allowed-in-name character
            // Check if text is not a part of tag or mention
            let regex = "^" + String(NSRegularExpression.nameRegexPattern.dropLast()) + "$"
            if !text.matches(regex) {
                // if appended
                if range.length == 0 {
                    // get range of last character
                    let lastLocation = range.location - 1
                    if lastLocation < 0 {
                        return true
                    }
                    // get last link attribute
                    let attr = textView.textStorage.attributes(at: lastLocation, effectiveRange: nil)
                    if attr.has(key: .link) {
                        textView.typingAttributes = textView.defaultTypingAttributes
                    }
                }
                // if inserted
            }
            
            // Remove link
            if text == "", range.length > 0, range.location > 0
            {
                contentTextView.removeLink()
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let attachment = textAttachment as? TextAttachment {
            showActionSheet(title: "choose action".localized().uppercaseFirst, message: nil, actions: [
                    UIAlertAction(title: "copy".localized().uppercaseFirst, style: .default, handler: { (_) in
                        self.copyAttachment(attachment)
                    }),
                    UIAlertAction(title: "cut".localized().uppercaseFirst, style: .default, handler: { (_) in
                        self.copyAttachment(attachment, completion: {
                            self.contentTextView.textStorage.replaceCharacters(in: characterRange, with: "")
                        })
                    }),
                    UIAlertAction(title: "preview".localized().uppercaseFirst, style: .default, handler: { (_) in
                        guard let type = attachment.embed?.type else {return}
                        switch type {
                        case "website", "video":
                            guard let urlString = attachment.embed?.url,
                                let url = URL(string: urlString) else {return}
                            let safariVC = SFSafariViewController(url: url)
                            self.present(safariVC, animated: true, completion: nil)
                        case "image":
                            if let localImage = attachment.localImage {
                                let appImage = ViewerImage.appImage(forImage: localImage)
                                let viewer = AppImageViewer(photos: [appImage])
                                self.present(viewer, animated: false, completion: nil)
                            }
                            else if let imageUrl = attachment.embed?.url,
                                let url = URL(string: imageUrl)
                            {
                                NetworkService.shared.downloadImage(url)
                                    .subscribe(onSuccess: { [weak self] (image) in
                                        let appImage = ViewerImage.appImage(forImage: image)
                                        let viewer = AppImageViewer(photos: [appImage])
                                        self?.present(viewer, animated: false, completion: nil)
                                    }, onError: { (error) in
                                        self.showError(error)
                                    })
                                    .disposed(by: self.disposeBag)
                            }
                        default:
                            break
                        }
                    })
                ])
            
            return false
        }
        return true
    }
    
    private func copyAttachment(_ attachment: TextAttachment, completion: (()->Void)? = nil) {
        self.showIndetermineHudWithMessage(
            "archiving".localized().uppercaseFirst)
        
        DispatchQueue(label: "archiving").async {
            if let data = try? JSONEncoder().encode(attachment) {
                UIPasteboard.general.setData(data, forPasteboardType: "attachment")
            }
            DispatchQueue.main.sync {
                self.hideHud()
                completion?()
            }
        }
    }
}
