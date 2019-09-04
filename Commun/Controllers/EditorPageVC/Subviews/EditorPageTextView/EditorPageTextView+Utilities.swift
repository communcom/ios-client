//
//  EditorPageTextView+Utilities.swift
//  Commun
//
//  Created by Chung Tran on 9/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension EditorPageTextView {
    func imageAttachment(from image: UIImage, urlString: String? = nil, description: String? = nil) -> TextAttachment {
        let attachmentRightMargin: CGFloat = 10
        let attachmentHeightForDescription: CGFloat = MediaView.descriptionDefaultHeight
        
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
        
        return attachment
    }
    
    func replaceCharacters(in range: NSRange, with attachment: TextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        textStorage.replaceCharacters(in: range, with: attachmentAS)
        textStorage.addAttributes(typingAttributes, range: NSMakeRange(range.location, 1))
    }
    
    func parseContent() -> Completable {
        var singles = [Observable<Void>]()
        textStorage.enumerateAttributes(in: NSMakeRange(0, textStorage.length), options: []) { (attrs, range, bool) in
            let text = textStorage.attributedSubstring(from: range).string
            
            // images
            if text.matches(pattern: "\\!\\[.*\\]\\(.*\\)") {
                let description = text.slicing(from: "[", to: "]")
                guard let urlString = text.slicing(from: "(", to: ")"),
                    let url         = URL(string: urlString)
                    else {return}
                let downloadImage = NetworkService.shared.downloadImage(url)
                    .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                    .do(onSuccess: { [weak self] (image) in
                        guard let strongSelf = self else {return}
                        let newRange = strongSelf.textStorage.nsRangeOfText(text)
                        let attachment = strongSelf.imageAttachment(from: image, urlString: urlString, description: description)
                        strongSelf.replaceCharacters(in: newRange, with: attachment)
                    })
                    .map {_ in ()}
                    .asObservable()
                singles.append(downloadImage)
            }
                
                // video or website
            else if text.matches(pattern: "\\!(video|website)\\[.*\\]\\(.*\\)") {
                guard let urlString = text.slicing(from: "(", to: ")") else {return}
                let downloadPreview = NetworkService.shared.downloadLinkPreview(urlString)
                    .flatMap {response -> Single<(UIImage, String?, String?)> in
                        if let imageUrlString = response.image,
                            let url = URL(string: imageUrlString) {
                            return NetworkService.shared.downloadImage(url)
                                .map {($0, urlString, response.title)}
                                .catchErrorJustReturn((UIImage(named: "image-not-available")!, urlString, response.title))
                        }
                        throw ErrorAPI.unknown
                    }
                    .catchErrorJustReturn((UIImage(named: "image-not-available")!, urlString, nil))
                    .do(onSuccess: { [weak self] (arg0) in
                        let (image, urlString, description) = arg0
                        guard let strongSelf = self else {return}
                        let newRange = strongSelf.textStorage.nsRangeOfText(text)
                        let attachment = strongSelf.imageAttachment(from: image, urlString: urlString, description: description)
                        if text.contains("!video") {
                            attachment.type = .video
                        } else if text.contains("!website") {
                            attachment.type = .website
                        }
                        
                        strongSelf.replaceCharacters(in: newRange, with: attachment)
                    })
                    .map {_ in ()}
                    .catchErrorJustReturn(())
                    .asObservable()
                singles.append(downloadPreview)
            }
        }
        
        guard singles.count > 0 else {return .empty()}
        
        return Observable.zip(singles)
            .take(1)
            .asSingle()
            .flatMapToCompletable()
    }
}
