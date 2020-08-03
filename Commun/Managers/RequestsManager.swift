//
//  RequestsManager.swift
//  Commun
//
//  Created by Chung Tran on 8/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class RequestsManager {
    // MARK: - Singleton
    static let `shared` = RequestsManager()
    private init() {}
    
    // MARK: - Nested type
    enum Request {
        case toggleLikePost(post: ResponseAPIContentGetPost, dislike: Bool = false)
        case toggleLikeComment(comment: ResponseAPIContentGetComment, dislike: Bool = false)
    }
    var pendingRequests = [Request]()
    
    func sendPendingRequests() -> Completable {
        let requests: [Completable] = pendingRequests.compactMap {
            switch $0 {
            case .toggleLikePost(let post, let dislike):
                return dislike ? post.downVote() : post.upVote()
            case .toggleLikeComment(let comment, let dislike):
                return dislike ? comment.downVote() : comment.upVote()
            }
        }
        
        return Completable.merge(requests)
            .do(onCompleted: {
               self.pendingRequests.removeAll()
            })
    }
}
