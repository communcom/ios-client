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
    
    /// set url = nil to remove
    func addImage(with url: String?) {
        guard let url = url else {
            embeds.removeAll(where: {($0["type"] as? String) == "photo"})
            return
        }
        
        if let i = embeds.firstIndex(where: {($0["type"] as? String) == "photo"}) {
            embeds[i]["url"] = url
        }
        
        #warning("add id")
        embeds.append([
            "type": "photo",
            "url": url,
            "id": Int(Date().timeIntervalSince1970)
        ])
    }
    
    func sendPost(with title: String, text: String, image: UIImage?) -> Single<NetworkService.SendPostCompletion> {
        if let post = postForEdit {
            #warning("Edit post and delete this line")
            return .error(ErrorAPI.requestFailed(message: "Editing post is implemented"))
        }
        
        var sendRequest: Single<NetworkService.SendPostCompletion> {
            let json = self.createJsonMetadata(for: text)
            return NetworkService.shared.sendPost(withTitle: title, withText: text, metaData: json ?? "", withTags: self.getTags(from: text))
        }
        
        
        if let image = image {
            return NetworkService.shared.uploadImage(image)
                .do(onSubscribed: {
                    UIApplication.topViewController()?.navigationController?.showIndetermineHudWithMessage("Upload image".localized())
                })
                .flatMap {url in
                    self.addImage(with: url)
                    return sendRequest
                }
        }
        
        return sendRequest
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
        var tags: [String] = []
        
        for word in text.components(separatedBy: " ") {
            if word.contains("#") {
                tags.append(word)
            }
        }
        
        if isAdult.value {
            tags.append("#18+")
        }
        
        return tags
    }
    
}
