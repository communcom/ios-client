//
//  EditorViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class PostEditorViewModel {
    var postForEdit: ResponseAPIContentGetPost?
    let community = BehaviorRelay<ResponseAPIContentGetCommunity?>(value: nil)
    
    func sendPost(title: String?, block: ResponseAPIContentBlock) -> Single<SendPostCompletion> {
        // If editing post
        var request: Single<SendPostCompletion>!
        
        if let post = self.postForEdit {
            request = BlockchainManager.instance.updateMessage(
                originMessage: post,
                communCode: community.value?.communityId ?? "",
                permlink: post.contentId.permlink,
                header: title ?? "",
                block: block
            )
        }
            
        // If creating new post
        else {
            request = BlockchainManager.instance.createMessage(
                communCode: community.value?.communityId ?? "",
                header: title ?? "",
                block: block
            )
        }
        
        // Request, then notify changes
        return request
            .do(onSuccess: { (_, _, _) in
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
