//
//  CommentFormViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class CommentFormViewModel {
    var post: ResponseAPIContentGetPost?
    
    func sendNewComment(
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community?.communityId,
            let authorId = post?.author?.userId,
            let postPermlink = post?.contentId.permlink
            else {return .error(CMError.invalidRequest(message: ErrorMessage.postInfoIsMissing.rawValue))}
        // Send request
        return BlockchainManager.instance.createMessage(
            isComment: true,
            parentPost: post,
            communCode: communCode,
            parentAuthor: authorId,
            parentPermlink: postPermlink,
            block: block,
            uploadingImage: uploadingImage
        )
    }
    
    func updateComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community?.communityId
        else {return .error(CMError.invalidRequest(message: ErrorMessage.postInfoIsMissing.rawValue))}
        
        // Send request
        return BlockchainManager.instance.updateMessage(
            originMessage: comment,
            communCode: communCode,
            permlink: comment.contentId.permlink,
            block: block,
            uploadingImage: uploadingImage
        )
    }
    
    func replyToComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community?.communityId
            else {return .error(CMError.invalidRequest(message: ErrorMessage.postInfoIsMissing.rawValue))}
        
        let authorId = comment.contentId.userId
        let parentCommentPermlink = comment.contentId.permlink
        // Send request
        return BlockchainManager.instance.createMessage(
            isComment: true,
            parentPost: post,
            isReplying: true,
            parentComment: comment,
            communCode: communCode,
            parentAuthor: authorId,
            parentPermlink: parentCommentPermlink,
            block: block,
            uploadingImage: uploadingImage
        )
    }
}
