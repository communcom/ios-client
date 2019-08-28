//
//  TextAttachment.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class TextAttachment: NSTextAttachment {
    enum AttachmentType {
        case image(originalImage: UIImage?), url
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
        case .url:
            return placeholder
        }
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
