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
    func toTextAttachmentSingle() -> Single<TextAttachment>? {
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
                let attachment = TextAttachment()
                attachment.embed = embed
                attachment.localImage = image
                return attachment
            }
    }
}
