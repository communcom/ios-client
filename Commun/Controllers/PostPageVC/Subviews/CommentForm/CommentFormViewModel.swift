//
//  CommentFormViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/19/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class CommentFormViewModel {
    var post: ResponseAPIContentGetPost?
    
    func sendNewComment(
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community.communityId,
            let authorId = post?.author?.userId,
            let postPermlink = post?.contentId.permlink
            else {return .error(ErrorAPI.invalidData(message: "Post info missing"))}
        // Send request
        return RestAPIManager.instance.createMessage(
            isComment:      true,
            parentPost:     post,
            communCode:     communCode,
            parentAuthor:   authorId,
            parentPermlink: postPermlink,
            block:          block
        )
    }
    
    func updateComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community.communityId
        else {return .error(ErrorAPI.invalidData(message: "Post info missing"))}
        
        
        // Send request
        return RestAPIManager.instance.updateMessage(
            originMessage:  comment,
            communCode:     communCode,
            permlink:       comment.contentId.permlink,
            block:          block
        )
    }
    
    func replyToComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community.communityId
            else {return .error(ErrorAPI.invalidData(message: "Post info missing"))}
        
        let authorId = comment.contentId.userId
        let parentCommentPermlink = comment.contentId.permlink
        // Send request
        return RestAPIManager.instance.createMessage(
            isComment:      true,
            parentPost:     post,
            isReplying:     true,
            parentComment:  comment,
            communCode:     communCode,
            parentAuthor:   authorId,
            parentPermlink: parentCommentPermlink,
            block:          block
        )
    }
}
