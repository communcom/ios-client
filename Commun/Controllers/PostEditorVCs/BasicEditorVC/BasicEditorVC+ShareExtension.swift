//
//  BasicEditorVC+ShareExtension.swift
//  Commun
//
//  Created by Chung Tran on 3/12/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    func loadShareExtensionData() {
        if let shareExtensionData = shareExtensionData {
            
            if let text = shareExtensionData.text {
                contentTextView.attributedText = NSAttributedString(string: text, attributes: contentTextView.defaultTypingAttributes)
            }
            
            if let urlString = shareExtensionData.link {
                parseLink(urlString)
            }
            
            if let imageData = shareExtensionData.imageData, let image = UIImage(data: imageData) {
                didChooseImageFromGallery(image)
            }
        }
    }
        
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        // Dismiss
        UIView.animate(withDuration: 0.20, animations: {
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (_) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
}
