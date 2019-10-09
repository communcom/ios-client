//
//  EditorViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class EditorViewModel {
    var postForEdit: ResponseAPIContentGetPost?
    var isAdult = false
    
    func sendPost(title: String, block: ResponseAPIContentBlock) -> Single<SendPostCompletion> {
        // Prepare tags
        var tags = block.getTags()
        if isAdult {tags.append("18+")}
        
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
            request = NetworkService.shared.editPostWithPermlink(post.contentId.permlink, title: title, text: string, metaData: "", withTags: tags)
        }
            
        // If creating new post
        else {
            request = NetworkService.shared.sendPost(withTitle: title, withText: string, metaData: "", withTags: tags)
        }
        
        // Request, then notify changes
        return request
            .do(onSuccess: { (transactionId, userId, permlink) in
                // if editing post, then notify changes
                if var post = self.postForEdit {
                    post.content.body = block
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
