//
//  EditorPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

class EditorPageViewModel {
    var postForEdit: ResponseAPIContentGetPost?
    
    let isAdult = BehaviorRelay<Bool>(value: false)
    var embeds = [[String: Any]]()
    
    func sendPost(with title: String, text attributedString: NSAttributedString) -> Single<SendPostCompletion> {
        let mutableAS = NSMutableAttributedString(attributedString: attributedString)
        
        // Prepare embeds
        embeds = [[String: Any]]()
        
        // Prepare tags
        var tags = mutableAS.string.getTags()
        
        if isAdult.value {
            tags.append("#18+")
        }
        
        // Detect links
        let types = NSTextCheckingResult.CheckingType.link
        if let detector = try? NSDataDetector(types: types.rawValue) {
            let matches = detector.matches(in: mutableAS.string, options: .reportCompletion, range: NSMakeRange(0, mutableAS.string.count))
            for match in matches {
                guard let urlString = match.url?.absoluteString else {
                    continue
                }
                if embeds.first(where: {($0["url"] as? String) == urlString}) != nil {continue}
                #warning("Define type")
                embeds.append(["url": urlString])
            }
        }

        // get attachments
        mutableAS.beginEditing()
        var attachments = [TextAttachment]()
        attributedString.enumerateAttribute(.attachment, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, stop) in
            if let attachment = value as? TextAttachment {
                attachments.append(attachment)
                mutableAS.replaceCharacters(in: range, with: attachment.placeholderText)
            }
        }
        mutableAS.endEditing()
        
        // parallelly uploading images
        let uploadImages = Observable.zip(
            attachments.reduce([]) { (result, attachment) -> [Observable<String>] in
                guard let type = attachment.type else {return result}
                switch type {
                case .image(let image, let urlString, _):
                    if let urlString = urlString {
                        return result + [.just(urlString)]
                    }
                    
                    return result + [
                        NetworkService.shared.uploadImage(image!)
                            .do(onSuccess: {imageURL in
                                mutableAS.mutableString.replaceOccurrences(of: attachment.placeholderText, with: attachment.placeholderText.replacingOccurrences(of: "()", with: "(\(imageURL))"), options: [], range: NSMakeRange(0, mutableAS.mutableString.length))
                            })
                            .asObservable()
                    ]
                case .url(_, _):
                    // TODO: later
                    return result
                }
            }
        ).take(1).asSingle()
        
        // Send request
        return uploadImages
            .do(onSubscribe: {
                UIApplication.topViewController()?.navigationController?
                    .showIndetermineHudWithMessage("upload image".localized().uppercaseFirst)
            })
            .flatMap({ (urls) in
                for url in urls {
                    self.embeds.append([
                        "type": "photo",
                        "url": url,
                        "id": Int(Date().timeIntervalSince1970)
                    ])
                }
                
                if let post = self.postForEdit {
                    return NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: mutableAS.string, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)
                } else {
                    return NetworkService.shared.sendPost(withTitle: title, withText: mutableAS.string, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)
                }
                
            })
    }
    
}
