//
//  EditorPageTextView+Attachment.swift
//  Commun
//
//  Created by Chung Tran on 9/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageTextView {
    // MARK: - Link
    func addLink(_ urlString: String, placeholder: String?) {
        // if link has placeholder
        if let placeholder = placeholder {
            var attrs = typingAttributes
            attrs[.link] = urlString
            let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
            attrStr.insert(NSAttributedString(string: String.invisible, attributes: typingAttributes), at: 0)
            attrStr.append(NSAttributedString(string: String.invisible, attributes: typingAttributes))
            textStorage.replaceCharacters(in: selectedRange, with: attrStr)
            selectedRange.location += 1
        }
            // if link is a separated block
        else {
            // detect link type
            NetworkService.shared.getEmbed(url: urlString)
            
            // show
        }
    }
    
    func removeLink() {
        if selectedRange.length > 0 {
            textStorage.removeAttribute(.link, range: selectedRange)
        }
            
        else if var range = textStorage.rangeOfLink(at: selectedRange.location) {
            textStorage.removeAttribute(.link, range: range)
            if range.location > 0 {
                var invisibleTextLocation = range.location - 1
                var invisibleTextRange = NSMakeRange(invisibleTextLocation, 1)
                if textStorage.attributedSubstring(from: invisibleTextRange).string == .invisible {
                    textStorage.replaceCharacters(in: invisibleTextRange, with: "")
                    range.location -= 1
                    invisibleTextLocation = range.location + range.length
                    
                    if invisibleTextLocation >= textStorage.length {return}
                    
                    invisibleTextRange = NSMakeRange(invisibleTextLocation, 1)
                    if textStorage.attributedSubstring(from: invisibleTextRange).string == .invisible {
                        textStorage.replaceCharacters(in: invisibleTextRange, with: "")
                    }
                }
            }
        }
    }
    
    // MARK: - Image
    func add(_ image: UIImage, to attachment: inout TextAttachment) {
        let attachmentRightMargin: CGFloat = 10
        let attachmentHeightForDescription: CGFloat = MediaView.descriptionDefaultHeight
        
        // setup view
        let newWidth = frame.size.width - attachmentRightMargin
        let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentHeightForDescription))
        mediaView.showCloseButton = false
        mediaView.setUp(image: image, url: attachment.embed?.url, description: attachment.embed?.description)
        addSubview(mediaView)
        
        attachment.view = mediaView
        mediaView.removeFromSuperview()
    }
    
    private func attach(image: UIImage, urlString: String? = nil, description: String? = nil) {
        // Insert Attachment
        var attachment = TextAttachment()
        
        // add embed to attachment
        guard let embed = try? ResponseAPIFrameGetEmbed(blockAttributes: ContentBlockAttributes(url: urlString, description: description)) else {
            return
        }
        attachment.embed = embed
        attachment.embed?.type = "image"
        
        // save localImage to download later, if urlString not found
        if urlString == nil {
            attachment.localImage = image
        }
        
        // add image to attachment
        add(image, to: &attachment)
        
        // attachmentAS to add
        let attachmentAS = NSMutableAttributedString()
        
        // insert an separator at the beggining of attachment if not exists
        if selectedRange.location > 0,
            textStorage.attributedSubstring(from: NSMakeRange(selectedRange.location - 1, 1)).string != "\n" {
            attachmentAS.append(NSAttributedString.separator)
        }
        
        attachmentAS.append(NSAttributedString(attachment: attachment))
        attachmentAS.append(NSAttributedString.separator)
        attachmentAS.addAttributes(typingAttributes, range: NSMakeRange(0, attachmentAS.length))
        
        // replace
        textStorage.replaceCharacters(in: selectedRange, with: attachmentAS)
    }
    
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            attach(image: image, urlString: urlString, description: description)
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            
            NetworkService.shared.downloadImage(url)
                .do(onSubscribe: {
                    self.parentViewController?.navigationController?
                        .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                })
                .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                .subscribe(
                    onSuccess: { [weak self] (image) in
                        guard let strongSelf = self else {return}
                        strongSelf.parentViewController?.navigationController?.hideHud()
                        strongSelf.attach(image: image, urlString: urlString, description: description)
                    },
                    onError: {[weak self] error in
                        self?.parentViewController?.navigationController?.hideHud()
                        self?.parentViewController?.showError(error)
                    }
                )
                .disposed(by: bag)
        } else {
            parentViewController?.showGeneralError()
        }
    }
}
