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

final class TextAttachment: NSTextAttachment {
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
            setView()
        }
    }
    
    fileprivate func setView() {
        guard let view = view else {return}
        image = view.toImage
    }
    
    var placeholderText: String {
        return "!\(embed?.type == "image" ? "": embed?.type ?? "")[\(embed?.description ?? "")](\(embed?.url ?? "id=\(id)"))"
    }
    
    override var description: String {
        return "TextAttachment(\(placeholderText))"
    }
    
    func toSingleContentBlock(id: inout UInt) -> Single<ContentBlock>? {
        guard var embed = embed,
            let type = embed.type
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

extension TextAttachment: Codable {
    enum CodingKeys: String, CodingKey {
        case embed
        case localImage
        case view
        case id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(embed, forKey: .embed)
        
        if let localImage = localImage {
            let imageData = NSKeyedArchiver.archivedData(withRootObject: localImage)
            try container.encode(imageData, forKey: .localImage)
        }
        
        if let view = view {
            let viewData = NSKeyedArchiver.archivedData(withRootObject: view)
            try container.encode(viewData, forKey: .view)
        }
    }
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        embed = try values.decode(ResponseAPIFrameGetEmbed.self, forKey: .embed)
        if let data = try? values.decode(Data.self, forKey: .localImage),
            let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIImage {
            localImage = image
        }
        
        if let view = NSKeyedUnarchiver.unarchiveObject(with: try values.decode(Data.self, forKey: .view)) as? UIView {
            self.view = view
        }
        
        defer {
            setView()
        }
    }
}
