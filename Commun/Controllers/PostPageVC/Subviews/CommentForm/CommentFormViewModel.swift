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
        // Prepare content
        let tags = block.getTags()
        var string: String!
        do {
            string = try block.jsonString()
        } catch {
            return .error(ErrorAPI.invalidData(message: "Could not parse data"))
        }
        
        // Send request
        return RestAPIManager.instance.createMessage(
            isComment:      true,
            communCode:     communCode,
            parentAuthor:   authorId,
            parentPermlink: postPermlink,
            body:           string,
            tags:           tags
        )
    }
    
    func updateComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community.communityId
        else {return .error(ErrorAPI.invalidData(message: "Post info missing"))}
        
        // Prepare content
        let tags = block.getTags()
        var string: String!
        do {
            string = try block.jsonString()
        } catch {
            return .error(ErrorAPI.invalidData(message: "Could not parse data"))
        }
        
        // Send request
        return RestAPIManager.instance.updateMessage(
            communCode:     communCode,
            permlink:       comment.contentId.permlink,
            body:           string,
            tags:           tags
        )
    }
    
    func replyToComment(
        _ comment: ResponseAPIContentGetComment,
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        guard let communCode = post?.community.communityId
            else {return .error(ErrorAPI.invalidData(message: "Post info missing"))}
        
        // Prepare content
        let tags = block.getTags()
        var string: String!
        do {
            string = try block.jsonString()
        } catch {
            return .error(ErrorAPI.invalidData(message: "Could not parse data"))
        }
        
        let authorId = comment.contentId.userId
        let parentCommentPermlink = comment.contentId.permlink
        // Send request
        return RestAPIManager.instance.createMessage(
            isComment: true,
            communCode: communCode,
            parentAuthor: authorId,
            parentPermlink: parentCommentPermlink,
            body: string,
            tags: tags
        )
    }
}
