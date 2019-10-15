//
//  ResponseAPIFrameGetEmbed.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension ResponseAPIFrameGetEmbed {
    init(blockAttributes: ResponseAPIContentBlockAttributes) throws {
        let data = try JSONEncoder().encode(blockAttributes)
        self = try JSONDecoder().decode(ResponseAPIFrameGetEmbed.self, from: data)
        if self.type == "image" {self.type = "photo"}
        if self.type == "website" {self.type = "link"}
    }
    

    func toTextAttachmentSingle(withSize size: CGSize, forTextView textView: UITextView) -> Single<TextAttachment>? {
        var embed = self
        guard embed.type != nil else {return nil}
        
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
            downloadImage =
                NetworkService.shared.downloadImage(URL(string: urlString!)!)
                    .catchErrorJustReturn(UIImage(named: "image-not-available")!)
        }
        
        return downloadImage
            .map { (image) -> TextAttachment in
                // Insert Attachment
                let attachment = TextAttachment(embed: embed, localImage: image, size: size)
                attachment.delegate = textView.parentViewController as? AttachmentViewDelegate
                return attachment
            }
    }
}
