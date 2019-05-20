//
//  EditorPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class EditorPageViewModel {
    
    let images = Variable<[UIImage]>([])
    let titleText = Variable<String>("Test")
    let contentText = Variable<String>("")
    let isAdult = Variable<Bool>(false)
    
    func addImage(_ image: UIImage) {
        self.images.value.append(image)
    }
    
    func setAdult() {
        isAdult.value = !isAdult.value
    }
    
    func sendPost() -> Completable {
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
