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
import CyberSwift

class ArticleEditorTextView: ContentTextView {
    // MARK: - Constants
    let embedsLimit = 15
    let videosLimit = 10
    override var draftKey: String { "ArticleEditorTextView.draftKey" }
    
    // MARK: - Properties
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: defaultFont]
    }
    
    override var acceptedPostType: String {
        return "article"
    }
    
    override var canContainAttachments: Bool {
        return true
    }
    
    // MARK: - Parsing
    override func parseAttachments() -> Completable {
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

            // don't know why, but has to add dummy text, length = 1
            textStorage.replaceCharacters(in: range, with: NSAttributedString(string: " "))

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
                singles.append(
                    Single<UIImage>.just(UIImage(named: "image-not-available")!)
                        .do(onSuccess: { [weak self] (image) in
                            guard let strongSelf = self else {return}
                            strongSelf.add(image, to: &attachment)
                            strongSelf.replaceCharacters(in: range, with: attachment)
                        })
                )
            }
        }

        guard singles.count > 0 else {return .empty()}

        return Single.zip(singles)
            .flatMapToCompletable()
    }
    
    // MARK: - ContentBlock
    override func getContentBlock(postTitle: String? = nil) -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt64 = 1
        
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
                var block = ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(
                        title: postTitle,
                        type: self.acceptedPostType,
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
                block.maxId = id
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(
                        title: postTitle,
                        type: self.acceptedPostType,
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
        }
    }
}
