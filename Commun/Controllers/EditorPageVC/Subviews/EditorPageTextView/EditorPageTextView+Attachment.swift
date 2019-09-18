//
//  EditorPageTextView+Attachment.swift
//  Commun
//
//  Created by Chung Tran on 9/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension EditorPageTextView {
    // MARK: - Methods
    private func addEmbed(_ embed: ResponseAPIFrameGetEmbed) {
        // modification needed because of type conflict
        var embed = embed
        guard embed.type != nil else {return}
        
        // url for images
        var urlString = embed.url
        
        // Fix conflict type
        if embed.type == "photo" {embed.type = "image"}
        if embed.type == "link" {embed.type = "website"}
        
        // thumbnail for website and video
        if embed.type == "website" || embed.type == "video" {
            urlString = embed.thumbnail_url
        }
        
        // request
        var downloadImage: Single<UIImage>
        if urlString == nil || URL(string: urlString!) == nil {
            downloadImage = .just(UIImage(named: "image-not-available")!)
        }
        else {
            downloadImage = NetworkService.shared.downloadImage(URL(string: urlString!)!)
        }
        
        // Donwload image
        downloadImage
            .do(onSubscribe: {
                self.parentViewController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .catchErrorJustReturn(UIImage(named: "image-not-available")!)
            .subscribe(
                onSuccess: { [weak self] (image) in
                    guard let strongSelf = self else {return}
                    strongSelf.parentViewController?.hideHud()
                    
                    // Insert Attachment
                    var attachment = TextAttachment()
                    attachment.embed = embed
                    
                    // Add image to attachment
                    strongSelf.add(image, to: &attachment)
                    
                    // Add attachment
                    strongSelf.addAttachmentAtSelectedRange(attachment)
                },
                onError: {[weak self] error in
                    self?.parentViewController?.hideHud()
                    self?.parentViewController?.showError(error)
                }
            )
            .disposed(by: bag)
    }
    
    // MARK: - Link
    func addLink(_ urlString: String, placeholder: String?) {
        // if link has placeholder
        if let placeholder = placeholder,
            !placeholder.isEmpty
        {
            var attrs = typingAttributes
            attrs[.link] = urlString
            let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
            textStorage.replaceCharacters(in: selectedRange, with: attrStr)
            let newSelectedRange = NSMakeRange(selectedRange.location + attrStr.length, 0)
            selectedRange = newSelectedRange
            typingAttributes = defaultTypingAttributes
        }
            // if link is a separated block
        else {
            // detect link type
            NetworkService.shared.getEmbed(url: urlString)
                .do(onSubscribe: {
                    self.parentViewController?
                        .showIndetermineHudWithMessage(
                            "loading".localized().uppercaseFirst)
                })
                .subscribe(onSuccess: {[weak self] embed in
                    self?.parentViewController?.hideHud()
                    self?.addEmbed(embed)
                }, onError: {error in
                    self.parentViewController?.hideHud()
                    self.parentViewController?.showError(error)
                })
                .disposed(by: bag)
            // show
        }
    }
    
    func removeLink() {
        if selectedRange.length > 0 {
            textStorage.removeAttribute(.link, range: selectedRange)
        }
            
        else if selectedRange.length == 0 {
            let attr = typingAttributes
            if let link = attr[.link] as? String,
                link.isLink
            {
                textStorage.enumerateAttribute(.link, in: NSMakeRange(0, textStorage.length), options: []) { (currentLink, range, stop) in
                    if currentLink as? String == link,
                        range.contains(selectedRange.location - 1)
                    {
                        textStorage.removeAttribute(.link, range: range)
                    }
                }
            }
        }
    }
    
    // MARK: - Image
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ContentBlockAttributes(
                url: urlString, description: description
            )
        )
        embed.type = "image"
        
        // if image is local image
        if let image = image {
            // Insert Attachment
            var attachment = TextAttachment()
            attachment.embed = embed
            attachment.localImage = image
            
            // Add image to attachment
            add(image, to: &attachment)
            
            // Add attachment
            addAttachmentAtSelectedRange(attachment)
        }
            
        // if image is from link
        else {
            addEmbed(embed)
        }
    }
}
