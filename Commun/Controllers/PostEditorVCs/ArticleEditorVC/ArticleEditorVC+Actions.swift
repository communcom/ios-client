//
//  ArticleEditorVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    // MARK: - overriding actions
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        _contentTextView.addImage(image, description: description)
    }
    
//    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
//        _contentTextView.addImage(nil, urlString: urlString, description: description)
//    }
    
    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        _contentTextView.addLink(urlString, placeholder: placeholder)
    }
}
