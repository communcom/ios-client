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
    
    func sendPost(with title: String, text: String, media: PreviewView.MediaType?) -> Single<SendPostCompletion> {
        // Prepare request
        var uploadImage: Single<String>?
        
        // Prepare embeds
        embeds = [[String: Any]]()
        if let media = media {
            switch media {
            case .image(let image, let imageUrl):
                if let image = image {
                    uploadImage = NetworkService.shared.uploadImage(image)
                        .do(onSuccess: {url in
                            self.embeds.append([
                                "type": "photo",
                                "url": url,
                                "id": Int(Date().timeIntervalSince1970)
                            ])
                        }, onSubscribe: {
                            UIApplication.topViewController()?.navigationController?
                                .showIndetermineHudWithMessage("upload image".localized().uppercaseFirst)
                        })
                } else if let url = imageUrl {
                    embeds.append([
                        "type": "photo",
                        "url": url,
                        "id": Int(Date().timeIntervalSince1970)
                    ])
                }
            case .linkFromText(let text):
                for word in text.components(separatedBy: " ") {
                    if word.contains("http://") || word.contains("https://") {
                        if embeds.first(where: {($0["url"] as? String) == word}) != nil {continue}
                        #warning("Define type")
                        embeds.append(["url": word])
                    }
                }
            }
        }
        
        // Prepare tags
        var tags = text.getTags()
        
        if isAdult.value {
            tags.append("#18+")
        }
        
        // Send request
        if let post = postForEdit {
            return uploadImage != nil ?
                uploadImage!.flatMap {_ in NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: text, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)} :
                NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: text, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)
        } else {
            return uploadImage != nil ?
                uploadImage!.flatMap {_ in NetworkService.shared.sendPost(withTitle: title, withText: text, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)}:
                NetworkService.shared.sendPost(withTitle: title, withText: text, metaData: ["embeds": self.embeds].jsonString() ?? "", withTags: tags)
        }
    }
    
}
