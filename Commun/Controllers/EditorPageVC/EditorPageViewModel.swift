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
    
    let images = BehaviorRelay<[UIImage]>(value: [])
    let titleText = BehaviorRelay<String>(value: "")
    let contentText = BehaviorRelay<String>(value: "")
    let isAdult = BehaviorRelay<Bool>(value: false)
    
    func addImage(_ image: UIImage) {
        var newImages = images.value
        newImages.append(image)
        self.images.accept(newImages)
    }
    
    func setAdult() {
        isAdult.accept(!isAdult.value)
    }
    
    func sendPost() -> Single<NetworkService.SendPostCompletion> {
        if let post = postForEdit {
            #warning("Edit post and delete this line")
            return .error(ErrorAPI.requestFailed(message: "Editing post is implemented"))
        }
        let json = createJsonMetadata()
        return NetworkService.shared.sendPost(withTitle: titleText.value, withText: contentText.value, metaData: json ?? "", withTags: getTags())
    }
    
    func createJsonMetadata() -> String? {
        var embeds: [[String: String]] = []
        
        for word in contentText.value.components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                embeds.append(["url": word])
            }
        }
        
        let result: [String: Any] = ["embeds": embeds]
        return result.jsonString()
    }
    
    func getTags() -> [String] {
        var tags: [String] = []
        
        for word in contentText.value.components(separatedBy: " ") {
            if word.contains("#") {
                tags.append(word)
            }
        }
        
        if isAdult.value == true {
            tags.append("#18+")
        }
        
        return tags
    }
    
}
