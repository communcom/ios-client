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
    func add(_ image: UIImage, to attachment: inout TextAttachment) {
        let attachmentRightMargin: CGFloat = 10
        let attachmentHeightForDescription: CGFloat = MediaView.descriptionDefaultHeight
        
        // setup view
        let newWidth = frame.size.width - attachmentRightMargin
        let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentHeightForDescription))
        mediaView.showCloseButton = false
        mediaView.setUp(image: image, url: attachment.embed?.url, description: attachment.embed?.description)
        addSubview(mediaView)
        
        attachment.view = mediaView
        mediaView.removeFromSuperview()
    }
    
    func replaceCharacters(in range: NSRange, with attachment: TextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        textStorage.replaceCharacters(in: range, with: attachmentAS)
        textStorage.addAttributes(typingAttributes, range: NSMakeRange(range.location, 1))
    }
    
    func parseContent() -> Completable {
        var singles = [Single<UIImage>]()
        
        textStorage.enumerateAttribute(.attachment, in: NSMakeRange(0, textStorage.length), options: []) { (value, range, bool) in
            // Get empty attachment
            guard var attachment = value as? TextAttachment,
                let embed = attachment.embed
            else {return}
            
            // get image url or thumbnail (for website or video)
            var imageURL = embed.url
            if embed.type == "video" || embed.type == "website" {
                imageURL = embed.thumbnail_url
            }
            
            // return a downloadSingle
            if let urlString = imageURL,
                let url = URL(string: urlString) {
                let downloadImage = NetworkService.shared.downloadImage(url)
                    .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                    .do(onSuccess: { [weak self] (image) in
                        guard let strongSelf = self else {return}
                        strongSelf.add(image, to: &attachment)
                        strongSelf.replaceCharacters(in: range, with: attachment)
                    })
                singles.append(downloadImage)
            }
            // return an error image if thumbnail not found
            else {
                singles.append(.just(UIImage(named: "image-not-available")!))
            }
        }
        
        guard singles.count > 0 else {return .empty()}
        
        return Single.zip(singles)
            .flatMapToCompletable()
    }
    
    func getContentBlock() -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ContentBlock>]()
        
        // get AS, which was separated by the Escaping String
        var attachmentRanges = [NSRange]()
        textStorage.enumerateAttributes(in: NSMakeRange(0, textStorage.length), options: []) { (attrs, range, bool) in
            // parse attachments
            if let _ = attrs[.attachment] as? TextAttachment {
                attachmentRanges.append(range)
            }
        }
        
        // parse attributed string
        var start = 0
        
        for range in attachmentRanges {
            // add text from start to attachment's location
            if range.location - start > 0 {
                let end = range.location - 1
                let rangeForText = NSMakeRange(start, end - start + 1)
                let subAS = textStorage.attributedSubstring(from: rangeForText)
                let components = subAS.components(separatedBy: "\n")
                for component in components {
                    if let block = component.toParagraphContentBlock(id: &id) {
                        contentBlocks.append(.just(block))
                    }
                }
            }
            
            // add attachment
            if let attachment = textStorage.attributes(at: range.location, effectiveRange: nil)[.attachment] as? TextAttachment,
                let single = attachment.toSingleContentBlock(id: &id)
            {
                contentBlocks.append(single)
            }
            
            // new start
            start = range.location + 1
            if start >= textStorage.length {
                break
            }
        }
        
        // add last
        if start < textStorage.length {
            let lastRange = NSMakeRange(start, textStorage.length - start)
            let subAS = textStorage.attributedSubstring(from: lastRange)
            let components = subAS.components(separatedBy: "\n")
            for component in components {
                if let block = component.toParagraphContentBlock(id: &id) {
                    contentBlocks.append(.just(block))
                }
            }
        }
        
        
        return Single.zip(contentBlocks)
            .map {contentBlocks -> ContentBlock in
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(),
                    content: .array(contentBlocks))
        }
    }
}
