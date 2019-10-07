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
    let draftKey = "ArticleEditorTextView.draftKey"
    
    // MARK: - Properties
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: defaultFont]
    }
    
    override var acceptedPostType: String {
        return "article"
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
    
    // MARK: - Draft
    override func saveDraft(completion: (()->Void)? = nil) {
        parentViewController?
            .showIndetermineHudWithMessage("archiving".localized().uppercaseFirst)
        var draft = [Data]()
        let aText = self.attributedText!
        DispatchQueue(label: "archiving").async {
            aText.enumerateAttributes(in: NSMakeRange(0, aText.length), options: []) { (attributes, range, stop) in
                if let attachment = attributes[.attachment] as? TextAttachment {
                    if let data = try? JSONEncoder().encode(attachment) {
                        draft.append(data)
                    }
                    return
                }
                if let data = try? aText.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
                {
                    draft.append(data)
                }
            }
            if let data = try? JSONEncoder().encode(draft) {
                UserDefaults.standard.set(data, forKey: self.draftKey)
            }
            DispatchQueue.main.async {
                self.parentViewController?.hideHud()
                completion?()
            }
        }
    }
    
    override func getDraft(completion: (()->Void)? = nil) {
        // show hud
        self.parentViewController?
            .showIndetermineHudWithMessage("retrieving draft".localized().uppercaseFirst)
        
        // retrieve draft on another thread
        DispatchQueue(label: "pasting").async {
            guard let data = UserDefaults.standard.data(forKey: self.draftKey),
                let draft = try? JSONDecoder().decode([Data].self, from: data) else {
                    DispatchQueue.main.async {
                        self.parentViewController?.hideHud()
                    }
                    return
            }
            
            let mutableAS = NSMutableAttributedString()
            for data in draft {
                var skip = false
                DispatchQueue.main.sync {
                    if let attachment = try? JSONDecoder().decode(TextAttachment.self, from: data)
                    {
                        let attachmentAS = NSAttributedString(attachment: attachment)
                        mutableAS.append(attachmentAS)
                        skip = true
                    }
                }
                
                if skip {continue}
                
                if let aStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
                {
                    mutableAS.append(aStr)
                }
            }
            
            DispatchQueue.main.async {
                // Has to modify font back to systemFont because of illegal font in data
                mutableAS.overrideFont(
                    replacementFont: self.defaultFont,
                    keepSymbolicTraits: true)
                
                // set attributedText
                self.attributedText = mutableAS
                
                // hide hud
                self.parentViewController?
                    .hideHud()
                
                completion?()
            }
        }
    }
    
    override func removeDraft() {
        UserDefaults.standard.removeObject(forKey: self.draftKey)
    }
    
    override var hasDraft: Bool {
        return UserDefaults.standard.dictionaryRepresentation().keys.contains(draftKey)
    }
}
