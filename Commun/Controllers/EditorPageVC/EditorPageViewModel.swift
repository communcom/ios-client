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
    
    func sendPost(with title: String, text: String) -> Single<NetworkService.SendPostCompletion> {
        if let post = postForEdit {
            #warning("Edit post and delete this line")
            return .error(ErrorAPI.requestFailed(message: "Editing post is implemented"))
        }
        let json = createJsonMetadata(for: text)
        return NetworkService.shared.sendPost(withTitle: title, withText: text, metaData: json ?? "", withTags: getTags(from: text))
    }
    
    func createJsonMetadata(for text: String) -> String? {
        var embeds: [[String: String]] = []
        
        for word in text.components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                embeds.append(["url": word])
            }
        }
        
        let result: [String: Any] = ["embeds": embeds]
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
