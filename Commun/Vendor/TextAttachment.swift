//
//  TextAttachment.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class TextAttachment: NSTextAttachment {
    enum AttachmentType {
        case image(originalImage: UIImage?)
        case website
        case video
    }
    
    private static var uniqueId = 0
    lazy var id: Int = {
        let id = TextAttachment.uniqueId
        TextAttachment.uniqueId += 1
        return id
    }()
    var type: AttachmentType?
    var desc: String?
    var urlString: String?
    var view: UIView? {
        didSet {
            image = view?.toImage
        }
    }
    
    var placeholderText: String {
        let placeholder = "[\(desc ?? "")](\(urlString ?? "id=\(id)"))"
        guard let type = type else {return placeholder}
        switch type {
        case .image(_):
            return "!\(placeholder)"
        case .website:
            return "!website\(placeholder)"
        case .video:
            return "!video\(placeholder)"
        }
    }
    
    override var description: String {
        return "TextAttachment(\(placeholderText))"
    }
    
    func toSingleContentBlock(id: inout UInt) -> Single<ContentBlock>? {
        guard let type = type else {
            print("Type of content is missing: \(self)")
            return nil
        }
        switch type {
        case .image(let originalImage):
            let blockType = "image"
            let attributes = ContentBlockAttributes(version: nil, title: nil, style: nil, text_color: nil, anchor: nil, url: nil, description: desc, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil)
            
            // if image was uploaded
            if let url = urlString {
                id += 1
                let block = ContentBlock(id: id, type: blockType, attributes: attributes, content: .string(url))
                return .just(block)
            }
                
            // have to upload image
            else if let image = originalImage {
                id += 1
                let newId = id
                let single: Single<ContentBlock> =
                    NetworkService.shared.uploadImage(image)
                        .map {url in
                            return ContentBlock(id: newId, type: blockType, attributes: attributes, content: .string(url))
                        }
                return single
            }
        case .website:
            guard let url = urlString else {break}
            // TODO: download descriptions, modify attributes
            id += 1
            let block = ContentBlock(
                id: id,
                type: "website",
                attributes:
                ContentBlockAttributes(version: nil, title: nil, style: nil, text_color: nil, anchor: nil, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                content: .string(url))
            
            return .just(block)
            
        case .video:
            guard let url = urlString else {break}
            // TODO: download descriptions, modify attributes
            id += 1
            let block = ContentBlock(
                id: id,
                type: "video",
                attributes:
                ContentBlockAttributes(version: nil, title: nil, style: nil, text_color: nil, anchor: nil, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                content: .string(url))
            return .just(block)
        }
        return nil
    }
}

private extension UIView {
    var toImage: UIImage {
        let image: UIImage
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: self.frame.size)
            image = renderer.image {
                self.layer.render(in: $0.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
            self.layer.render(in: UIGraphicsGetCurrentContext()! )
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return image
    }
}
