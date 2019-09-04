//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SwiftLinkPreview
import RxSwift
import CyberSwift

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .bold), color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string:text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }
    
    @discardableResult func semibold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold), color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string:text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func gray(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs).colored(with: UIColor.gray)
        append(normal)
        return self
    }
    
    @discardableResult func underline(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .underlineStyle: NSUnderlineStyle.single]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
    
    func imageAttachment(from image: UIImage, urlString: String? = nil, description: String? = nil, into view: UIView) -> TextAttachment {
        let attachmentRightMargin: CGFloat = 10
        let attachmentHeightForDescription: CGFloat = MediaView.descriptionDefaultHeight
        
        // setup view
        let newWidth = view.frame.size.width - attachmentRightMargin
        let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentHeightForDescription))
        mediaView.showCloseButton = false
        mediaView.setUp(image: image, url: urlString, description: description)
        view.addSubview(mediaView)
        
        // setup attachment
        let attachment = TextAttachment()
        attachment.urlString    = urlString
        attachment.desc         = description
        attachment.view         = mediaView
        attachment.type         = .image(originalImage: image)
        mediaView.removeFromSuperview()
        
        return attachment
    }
    
    func parseContent(into view: UIView) -> Completable {
        var singles = [Observable<Void>]()
        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attrs, range, bool) in
            let text = attributedSubstring(from: range).string
            
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
                        let newRange = strongSelf.nsRangeOfText(text)
                        let attachment = strongSelf.imageAttachment(from: image, urlString: urlString, description: description, into: view)
                        let imageAS = NSAttributedString(attachment: attachment)
                        strongSelf.replaceCharacters(in: newRange, with: imageAS)
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
                        let newRange = strongSelf.nsRangeOfText(text)
                        let attachment = strongSelf.imageAttachment(from: image, urlString: urlString, description: description, into: view)
                        if text.contains("!video") {
                            attachment.type = .video
                        } else if text.contains("!website") {
                            attachment.type = .website
                        }
                        
                        let imageAS = NSAttributedString(attachment: attachment)
                        strongSelf.replaceCharacters(in: newRange, with: imageAS)
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
    
    func toContentBlock() -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ContentBlock>]()
        
        // get AS, which was separated by the Escaping String
        var currentParagraph: NSMutableAttributedString?
        enumerateAttributes(in: NSMakeRange(0, length), options: []) { (attrs, range, bool) in
            // parse attachments
            if let attachment = attrs[.attachment] as? TextAttachment {
                if let paragraph = currentParagraph,
                    let block = paragraph.toParagraphContentBlock(id: &id){
                    contentBlocks.append(.just(block))
                    currentParagraph = nil
                }
                if let single = attachment.toSingleContentBlock(id: &id) {
                    contentBlocks.append(single)
                }
            }
            
            else {
                if currentParagraph == nil {
                    currentParagraph = NSMutableAttributedString()
                }
                currentParagraph?.append(attributedSubstring(from: range))
            }
        }
        
        // apend last currentParagraph
        if let paragraph = currentParagraph,
            let block = paragraph.toParagraphContentBlock(id: &id){
            contentBlocks.append(.just(block))
            currentParagraph = nil
        }

        return Single.zip(contentBlocks)
            .map {contentBlocks -> ContentBlock in
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(version: 1, title: nil, style: nil, text_color: nil, anchor: nil, url: nil, description: nil, provider_name: nil, author: nil, author_url: nil, thumbnail_url: nil, thumbnail_size: nil, html: nil),
                    content: .array(contentBlocks))
            }
    }
}
