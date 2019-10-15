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
import SubviewAttachingTextView

final class TextAttachment: SubviewTextAttachment {
    private static var uniqueId = 0
    lazy var id: Int = {
        let id = TextAttachment.uniqueId
        TextAttachment.uniqueId += 1
        return id
    }()
    
    // embed
    var size: CGSize?
    var embed: ResponseAPIFrameGetEmbed?
    var localImage: UIImage?
    var attachmentView: AttachmentView?
    
    weak var delegate: AttachmentViewDelegate? {
        didSet {
            attachmentView?.delegate = delegate
        }
    }
    
    var placeholderText: String {
        return "!\(embed?.type == "image" ? "": embed?.type ?? "")[\(embed?.description ?? "")](\(embed?.url ?? "id=\(id)"))"
    }
    
    override var description: String {
        return "TextAttachment(\(placeholderText))"
    }
    
    convenience init(embed: ResponseAPIFrameGetEmbed?, localImage: UIImage?, size: CGSize) {
        let attachmentView = AttachmentView(frame: .zero)
        attachmentView.setUp(image: localImage, url: embed?.url, description: embed?.title ?? embed?.description)
        self.init(view: attachmentView, size: size)
        self.embed = embed
        self.localImage = localImage
        self.size = size
        self.attachmentView = attachmentView
        defer {
            attachmentView.attachment = self
        }
    }
    
    func toSingleContentBlock(id: inout UInt64) -> Single<ResponseAPIContentBlock>? {
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
                        return ResponseAPIContentBlock(
                            id: newId,
                            type: "image",
                            attributes: ResponseAPIContentBlockAttributes(embed: embed),
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
            ResponseAPIContentBlock(
                id: id,
                type: type,
                attributes: ResponseAPIContentBlockAttributes(embed: embed),
                content: .string(url!))
        )
    }
}

extension TextAttachment: Codable {
    enum CodingKeys: String, CodingKey {
        case embed
        case localImage
        case id
        case size
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(embed, forKey: .embed)
        try container.encode(size, forKey: .size)
        
        if let localImage = localImage {
            let imageData = NSKeyedArchiver.archivedData(withRootObject: localImage)
            try container.encode(imageData, forKey: .localImage)
        }
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(Int.self, forKey: .id)
        let embed = try values.decode(ResponseAPIFrameGetEmbed.self, forKey: .embed)
        let size = try values.decode(CGSize.self, forKey: .size)
        
        var localImage: UIImage?
        if let data = try? values.decode(Data.self, forKey: .localImage),
            let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIImage {
            localImage = image
        }
        
        // setup view
        // temporary size
        self.init(embed: embed, localImage: localImage, size: size)
        
        // reassign id
        self.id = id
        
    }
}
