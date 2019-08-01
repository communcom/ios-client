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
    let imageChanged = BehaviorRelay<Bool>(value: false)
    
    var embeds = [[String: Any]]()
    
    /// set url = nil to remove
    func addImage(with url: String?) {
        guard let url = url else {
            embeds.removeAll(where: {($0["type"] as? String) == "photo"})
            return
        }
        
        if let i = embeds.firstIndex(where: {($0["type"] as? String) == "photo"}) {
            embeds[i]["url"] = url
            return
        }
        
        #warning("add id")
        embeds.append([
            "type": "photo",
            "url": url,
            "id": Int(Date().timeIntervalSince1970)
        ])
    }
    
    func sendPost(with title: String, text: String, image: UIImage?) -> Single<SendPostCompletion> {
        
        var request: () -> Single<SendPostCompletion>
        if let post = postForEdit {
            request = {
                let json = self.createJsonMetadata(for: text)
                let tags = self.getTags(from: text)
                return NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: text, metaData: json ?? "", withTags: tags)
            }
        } else {
            request = {
                let json = self.createJsonMetadata(for: text)
                let tags = self.getTags(from: text)
                return NetworkService.shared.sendPost(withTitle: title, withText: text, metaData: json ?? "", withTags: tags)
            }
        }
        
        if let image = image, imageChanged.value {
            return NetworkService.shared.uploadImage(image)
                .do(onSubscribed: {
                    UIApplication.topViewController()?.navigationController?.showIndetermineHudWithMessage("Upload image".localized())
                })
                .flatMap {url in
                    self.addImage(with: url)
                    return request()
                }
        }
        
        return request()
    }
    
    func createJsonMetadata(for text: String) -> String? {
        for word in text.components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                if embeds.first(where: {($0["url"] as? String) == word}) != nil {continue}
                #warning("Define type")
                embeds.append(["url": word])
            }
        }
        
        let result = ["embeds": embeds]
        return result.jsonString()
    }
    
    func getTags(from text: String) -> [String] {
        var tags = text.getTags()
        
        if isAdult.value {
            tags.append("#18+")
        }
        
        return tags
    }
    
}
