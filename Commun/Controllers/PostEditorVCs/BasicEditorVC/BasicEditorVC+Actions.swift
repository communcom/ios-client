//
//  BasicEditorVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    // MARK: - overriding actions

    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        if link != nil {return}
        var attributes = ResponseAPIContentBlockAttributes(
            description: description
        )
        attributes.type = "image"
        
        let attachment = TextAttachment(attributes: attributes, localImage: image, size: CGSize(width: view.size.width, height: attachmentHeight))
        attachment.delegate = self
        
        // Add embeds
        _viewModel.addAttachment(attachment)
    }

    //    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
    //        parseLink(urlString)
    //    }

    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        if let placeholder = placeholder,
            !placeholder.isEmpty
        {
            _contentTextView.addLink(urlString, placeholder: placeholder)
        }
        else {
            parseLink(urlString)
        }
        
    }
}
