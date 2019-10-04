//
//  EditorPageTextView+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

extension ArticleEditorTextView {
    func parseText(_ string: String) {
        // Plain string
        var attributedText = NSAttributedString(string: string, attributes: defaultTypingAttributes)
        originalAttributedString = attributedText
        
        // Parse data
        if let jsonData = string.data(using: .utf8),
            let block = try? JSONDecoder().decode(ContentBlock.self, from: jsonData) {
            attributedText = block.toAttributedString(currentAttributes: typingAttributes)
        }
        
        // Asign raw value first
        self.attributedText = attributedText
        
        // Parse medias
        parseContent()
            .do(onSubscribe: {
                self.parentViewController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .subscribe(onCompleted: { [weak self] in
                self?.parentViewController?.hideHud()
                self?.originalAttributedString = self?.attributedText
            }) { [weak self] (error) in
                self?.parentViewController?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func parseContent() -> Completable {
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
