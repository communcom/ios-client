//
//  NonAuthCommentForm.swift
//  Commun
//
//  Created by Chung Tran on 8/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class NonAuthCommentForm: CommentForm {
    override func createRequest(parsedBlock: ResponseAPIContentBlock) -> Single<SendPostCompletion> {
        guard let post = post else {return .never()}
        
        //clean
        var block = parsedBlock
        block.maxId = nil
        
        let request: RequestsManager.Request
        switch self.mode {
        case .new:
            RequestsManager.shared.pendingRequests.removeAll(where: {
                switch $0 {
                case .newComment:
                    return true
                default:
                    return false
                }
            })
            request = RequestsManager.Request.newComment(post: post, block: block, uploadingImage: self.localImage.value)
        case .reply:
            RequestsManager.shared.pendingRequests.removeAll(where: {
                switch $0 {
                case .replyToComment:
                    return true
                default:
                    return false
                }
            })
            request = RequestsManager.Request.replyToComment(self.parentComment!, post: post, block: block, uploadingImage: self.localImage.value)
        default:
            return .never()
        }
        
        RequestsManager.shared.pendingRequests.append(request)
        
        (self.parentViewController as? NonAuthVCType)?.showAuthVC()
        
        return .never()
    }
}
