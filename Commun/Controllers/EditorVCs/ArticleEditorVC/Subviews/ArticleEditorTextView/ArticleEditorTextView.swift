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
}
