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

protocol TextAttachmentType: class {
    init(block: ResponseAPIContentBlock, size: CGSize)
}

final class TextAttachment: SubviewTextAttachment, TextAttachmentType {
    private static var uniqueId = 0
    lazy var id: Int = {
        let id = TextAttachment.uniqueId
        TextAttachment.uniqueId += 1
        return id
    }()
    
    // embed
    var size: CGSize?
    var attributes: ResponseAPIContentBlockAttributes?
    var localImage: UIImage?
    var attachmentView: AttachmentView?
    var type: String? {
        return attributes?.type
    }
    
    weak var delegate: AttachmentViewDelegate? {
        didSet {
            attachmentView?.delegate = delegate
        }
    }
    
    var placeholderText: String {
        return "!\(attributes?.type == "image" ? "": attributes?.type ?? "")[\(attributes?.description ?? "")](\(attributes?.url ?? "id=\(id)"))"
    }
    
    override var description: String {
        return "TextAttachment(\(placeholderText))"
    }
    
    convenience init(attributes: ResponseAPIContentBlockAttributes?, localImage: UIImage?, size: CGSize) {
        let attachmentView = AttachmentView(frame: .zero)
        attachmentView.setUp(image: localImage, url: attributes?.url, description: attributes?.title ?? attributes?.description)
        self.init(view: attachmentView, size: size)
        self.attributes = attributes
        self.localImage = localImage
        self.size = size
        self.attachmentView = attachmentView
        defer {
            attachmentView.attachment = self
        }
    }
    
    convenience init(block: ResponseAPIContentBlock, size: CGSize) {
        let attachmentView = AttachmentView(frame: .zero)
        attachmentView.setUp(block: block)
        self.init(view: attachmentView, size: size)
        self.attributes = block.attributes
        self.size = size
        self.attachmentView = attachmentView
        defer {
            attachmentView.attachment = self
        }
    }
    
    func toSingleContentBlock(id: inout UInt64) -> Single<ResponseAPIContentBlock>? {
        guard var attributes = attributes,
            let type = attributes.type
        else {
            return nil
        }
        
        // Prevent sending html
        attributes.html = nil
        
        let url = attributes.url
        if url == nil {
            if type == "image", let image = localImage {
                id += 1
                let newId = id
                return NetworkService.shared.uploadImage(image)
                    .map { url in
                        attributes.url = url
                        return ResponseAPIContentBlock(
                            id: newId,
                            type: "image",
                            attributes: nil,
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
                attributes: nil,
                content: .string(url!))
        )
    }
}

extension TextAttachment: Codable {
    enum CodingKeys: String, CodingKey {
        case attributes
        case localImage
        case id
        case size
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(size, forKey: .size)
        
        if let localImage = localImage {
            let imageData = NSKeyedArchiver.archivedData(withRootObject: localImage)
            try container.encode(imageData, forKey: .localImage)
        }
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(Int.self, forKey: .id)
        let attributes = try values.decode(ResponseAPIContentBlockAttributes.self, forKey: .attributes)
        let size = try values.decode(CGSize.self, forKey: .size)
        
        var localImage: UIImage?
        if let data = try? values.decode(Data.self, forKey: .localImage),
            let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIImage {
            localImage = image
        }
        
        // setup view
        // temporary size
        self.init(attributes: attributes, localImage: localImage, size: size)
        
        // reassign id
        self.id = id
        
    }
}
