//
//  EditorPageTextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage

class EditorPageTextView: ExpandableTextView {
    // MARK: - Properties
    let bag = DisposeBag()
    
    // options
    private let attachmentRightMargin: CGFloat = 10
    private let attachmentHeightForDescription: CGFloat = 80
    
    // MARK: - Methods
    private func attach(image: UIImage, urlString: String? = nil, description: String? = nil, at index: Int? = nil) {
        // setup view
        let newWidth = frame.size.width - attachmentRightMargin
        let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentHeightForDescription))
        mediaView.showCloseButton = false
        mediaView.setUp(image: image, url: urlString, description: description)
        addSubview(mediaView)
        
        // setup attachment
        let attachment = TextAttachment()
        attachment.urlString    = urlString
        attachment.desc         = description
        attachment.view         = mediaView
        attachment.type         = .image(originalImage: image)
        mediaView.removeFromSuperview()
        
        // Insert Attachment
        let currentAtStr = NSMutableAttributedString(attributedString: attributedText)
        let attachmentAtStr = NSAttributedString(attachment: attachment)
        if let index = index {
            currentAtStr.insert(attachmentAtStr, at: index)
        } else {
            currentAtStr.append(attachmentAtStr)
        }
        currentAtStr.addAttributes(typingAttributes, range: NSMakeRange(0, currentAtStr.length))
        attributedText = currentAtStr
    }
    
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            attach(image: image, urlString: urlString, description: description)
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            let textAttachment = TextAttachment()
            textAttachment.urlString    = urlString
            textAttachment.desc         = description
            insertText(textAttachment.placeholderText)
            
            let manager = SDWebImageManager.shared()
            
            manager.imageDownloader?.downloadImage(with: url, completed: {[weak self] (image, data, error, _) in
                guard let strongSelf = self else {return}
                
                // current location of placeholder
                let location = strongSelf.nsRangeOfText(textAttachment.placeholderText).location
                
                guard location >= 0 else {return}
                
                // attach image
                if let image = image {
                    strongSelf.attach(image: image, urlString: urlString, description: description, at: location)
                    strongSelf.removeText(textAttachment.placeholderText)
                } else {
                    strongSelf.parentViewController?.showErrorWithLocalizedMessage("could not load image".localized().uppercaseFirst + "with URL".localized() + " " + urlString)
                }
            })
        } else {
            parentViewController?.showGeneralError()
        }
    }
    
    func parseText(_ text: String?) {
        guard let text = text,
            let regex = try? NSRegularExpression(pattern: "\\[.*\\]\\(.*\\)", options: .caseInsensitive)
        else {return}
        // assign text
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(typingAttributes, range: NSMakeRange(0, attributedString.length))
        attributedText = attributedString
        
        let imageDownloader = SDWebImageManager.shared().imageDownloader
        
        // find embeds
        for match in regex.matchedStrings(in: text) {
            
            let description = match.slicing(from: "[", to: "]")
            guard let urlString = match.slicing(from: "(", to: ")"),
                let url         = URL(string: urlString)
            else {continue}
            
            imageDownloader?.downloadImage(with: url, completed: { [weak self] (image, _, error, _) in
                guard let strongSelf = self else {return}
                // attach image
                if let image = image {
                    let location = text.nsString.range(of: match).location
                    strongSelf.attach(image: image, urlString: urlString, description: description, at: location)
                    strongSelf.removeText(match)
                }
            })
        }
    }
}
