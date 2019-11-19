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

class PostEditorViewModel {
    var postForEdit: ResponseAPIContentGetPost?
    let community = BehaviorRelay<ResponseAPIContentGetSubscriptionsCommunity?>(value: nil)
    
    func sendPost(title: String?, block: ResponseAPIContentBlock) -> Single<SendPostCompletion> {
        // Prepare tags
        let tags = block.getTags()
        
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
            request = RestAPIManager.instance.rx.updateMessage(
                communCode:     community.value?.communityId ?? "",
                permlink:       post.contentId.permlink,
                header:         title ?? "",
                body:           string,
                tags:           tags
            )
        }
            
        // If creating new post
        else {
            request = RestAPIManager.instance.rx.createMessage(
                communCode:     community.value?.communityId ?? "",
                header:         title ?? "",
                body:           string,
                tags:           tags
            )
        }
        
        // Request, then notify changes
        return request
            .do(onSuccess: { (transactionId, userId, permlink) in
                // if editing post, then notify changes
                if var post = self.postForEdit {
                    post.document = block
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
