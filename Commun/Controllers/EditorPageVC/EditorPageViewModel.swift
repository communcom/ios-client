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
    
    private var embeds = [[String: Any]]()
    
    func sendPost(title: String, block: ContentBlock) -> Single<SendPostCompletion> {
        // Prepare embeds
        embeds = [[String: Any]]()
        switch block.content {
        case .array(let childBlocks):
            embeds = childBlocks.compactMap({ (block) -> [String: Any]? in
                if block.type == "image" {
                    return [
                        "type": "photo",
                        "url": block.content.stringValue!,
                        "id": Int(Date().timeIntervalSince1970)
                    ]
                }
                
                if block.type == "video" || block.type == "website" {
                    return [
                        "url": block.content.stringValue!
                    ]
                }
                return nil
            })
        case .string(_):
            break
        case .unsupported:
            return .error(ErrorAPI.invalidData(message: "Content is invalid"))
        }
        
        // Prepare tags
        var tags = block.getTags()
        if isAdult.value {tags.append("18+")}
        
        // Prepare content
        var string: String!
        do {
            string = try block.jsonString()
        } catch {
            return .error(ErrorAPI.invalidData(message: "Could not parse data"))
        }
        
        // If editing post
        var request: Single<SendPostCompletion>!
        if let post = self.postForEdit {
            request = NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: string, metaData: ["embeds": embeds].jsonString() ?? "", withTags: tags)
        }
            
        // If creating new post
        else {
            request = NetworkService.shared.sendPost(withTitle: title, withText: string, metaData: ["embeds": embeds].jsonString() ?? "", withTags: tags)
        }
        
        // Request, then notify changes
        return request
            .do(onSuccess: { (transactionId, userId, permlink) in
                // if editing post, then notify changes
                if var post = self.postForEdit {
                    post.content.title = title
                    post.content.body.full = try block.jsonString()
                    if let imageURL = self.embeds.first(where: {($0["type"] as? String) == "photo"})?["url"] as? String,
                        let embeded = post.content.embeds.first,
                        embeded.type == "photo" {
                        post.content.embeds[0].result?.url = imageURL
                    }
                    post.notifyChanged()
                }
            })
    }
    
    func waitForTransaction(_ sendPostCompletion: SendPostCompletion) -> Single<(userId: String, permlink: String)> {
        guard let id = sendPostCompletion.transactionId,
            let userId = sendPostCompletion.userId,
            let permlink = sendPostCompletion.permlink else {
                return .error(ErrorAPI.responseUnsuccessful(message: "post not found".localized().uppercaseFirst))
        }
        
        return NetworkService.shared.waitForTransactionWith(id: id)
            .observeOn(MainScheduler.instance)
            .andThen(Single<(userId: String, permlink: String)>.just((userId: userId, permlink: permlink)))
        
    }
}
