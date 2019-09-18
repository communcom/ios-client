//
//  TextAttachment.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class TextAttachment: NSTextAttachment {
    private static var uniqueId = 0
    lazy var id: Int = {
        let id = TextAttachment.uniqueId
        TextAttachment.uniqueId += 1
        return id
    }()
    
    // embed
    var embed: ResponseAPIFrameGetEmbed?
    var localImage: UIImage?
    
    var view: UIView? {
        didSet {
            image = view?.toImage
        }
    }
    
    var placeholderText: String {
        return "!\(embed?.type == "image" ? "": embed?.type ?? "")[\(embed?.description ?? "")](\(embed?.url ?? "id=\(id)"))"
    }
    
    override var description: String {
        return "TextAttachment(\(placeholderText))"
    }
    
    func toSingleContentBlock(id: inout UInt) -> Single<ContentBlock>? {
        guard var embed = embed,
            var type = embed.type
        else {
            return nil
        }
        
        // Prevent sending html
        embed.html = nil
        
        let url = embed.url
        if url == nil {
            if type == "image", let image = localImage {
                id += 1
                let newId = id
                return NetworkService.shared.uploadImage(image)
                    .map { url in
                        embed.url = url
                        return ContentBlock(
                            id: newId,
                            type: "image",
                            attributes: ContentBlockAttributes(embed: embed),
                            content: .string(url))
                    }
            }
            else {
                // TODO: support uploading image
                return nil
            }
        }
        
        id += 1
        return .just(
            ContentBlock(
                id: id,
                type: type,
                attributes: ContentBlockAttributes(embed: embed),
                content: .string(url!))
        )
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
