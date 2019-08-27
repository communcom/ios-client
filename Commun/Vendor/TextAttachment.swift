//
//  TextAttachment.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RTViewAttachment

class TextAttachment: RTViewAttachment {
    private static var uniqueId = 0
    enum AttachmentType {
        case image(image: UIImage?, urlString: String?, description: String?)
        case url(url: String, description: String?)
    }
    var id: Int!
    var type: AttachmentType? {
        didSet {
            guard let type = type else {return}
            switch type {
            case .image(_, let urlString, let description):
                placeholderText = "[\(description ?? "")](\(urlString ?? "id=\(id!)"))"
            case .url(let url, let description):
                placeholderText = "[\(description ?? "")](\(url))"
            }
        }
    }
    
    // MARK: - Initializers
    override init!(view: UIView!, placeholderText text: String!) {
        super.init(view: view, placeholderText: text)
        generateUniqueId()
    }
    
    override init!(view: UIView!, placeholderText text: String!, fullWidth: Bool) {
        super.init(view: view, placeholderText: text, fullWidth: fullWidth)
        generateUniqueId()
    }
    
    override init!(view: UIView!) {
        super.init(view: view)
        generateUniqueId()
    }
    
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        generateUniqueId()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateUniqueId()
    }
    
    private func generateUniqueId() {
        id = TextAttachment.uniqueId
        TextAttachment.uniqueId += 1
    }
}
