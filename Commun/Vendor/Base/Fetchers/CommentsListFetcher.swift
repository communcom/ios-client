//
//  CommentsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

public var maxNestedLevel = 6
//    var maxNestedLevel = 6
class CommentsListFetcher: ListFetcher<ResponseAPIContentGetComment> {
    // MARK: - Properties
    let shouldGroupComments: Bool

    // MARK: - type
    struct GroupedComment {
       var comment: ResponseAPIContentGetComment
       var replies = [GroupedComment]()
    }
    
    // MARK: - Enums
    struct Filter: FilterType {
        var sortBy: CommentSortMode = .timeDesc
        var type: GetCommentsType
        var userId: String?
        var permlink: String?
        var communityId: String?
        var parentComment: ResponseAPIContentId?
        var resolveNestedComments: Bool = false
        var authorizationRequired: Bool = true
        
        func newFilter(
            withSortBy sortBy: CommentSortMode? = nil,
            type: GetCommentsType? = nil,
            userId: String? = nil,
            permlink: String? = nil,
            communityId: String? = nil,
            communityAlias: String? = nil,
            parentComment: ResponseAPIContentId? = nil,
            resolveNestedComments: Bool? = nil
        ) -> Filter {
            var newFilter = self
            
            if let sortBy = sortBy {
                newFilter.sortBy = sortBy
            }
            
            if let type = type {
                newFilter.type = type
            }
            
            if let userId = userId {
                newFilter.userId = userId
            }
            
            if let permlink = permlink {
                newFilter.permlink = permlink
            }
            if let communityId = communityId {
                newFilter.communityId = communityId
            }
            if let parentComment = parentComment {
                newFilter.parentComment = parentComment
            }
            if let resolveNestedComments = resolveNestedComments {
                newFilter.resolveNestedComments = resolveNestedComments
            }
            return newFilter
        }
    }
    
    var filter: Filter
    
    init(filter: Filter, shouldGroupComments: Bool) {
        self.filter = filter
        self.shouldGroupComments = shouldGroupComments
    }
        
    override var request: Single<[ResponseAPIContentGetComment]> {
        var result: Single<ResponseAPIContentGetComments>
                
        //        #warning("mocking")
        //        return ResponseAPIContentGetComments.singleWithMockData()
        //            .map {$0.items!}
                
        switch filter.type {
        case .post:
            // get post's comment
            result = RestAPIManager.instance.loadPostComments(
                sortBy: filter.sortBy,
                offset: offset,
                limit: 30,
                userId: filter.userId,
                permlink: filter.permlink ?? "",
                communityId: filter.communityId,
                authorizationRequired: filter.authorizationRequired
            )
        
        case .user:
            result = RestAPIManager.instance.loadUserComments(
                sortBy: filter.sortBy,
                offset: offset,
                limit: 30,
                userId: filter.userId,
                authorizationRequired: filter.authorizationRequired
            )
            maxNestedLevel = 0

        case .replies:
            result = RestAPIManager.instance.loadPostComments(
                sortBy: filter.sortBy,
                offset: offset,
                limit: 30,
                permlink: filter.permlink ?? "",
                communityId: filter.communityId,
                parentCommentUserId: filter.parentComment?.userId,
                parentCommentPermlink: filter.parentComment?.permlink,
                authorizationRequired: filter.authorizationRequired
            )
        }
        
        return result
            .map {$0.items ?? []}
    }
    
    override func join(newItems items: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        var newList = super.join(newItems: items)
        // sort
        if shouldGroupComments {
            newList = groupComments(newList)
        }
        return newList
    }
    
    override func handleNewData(_ items: [ResponseAPIContentGetComment]) {
        super.handleNewData(items)
        loadDonations(forComments: items)
        sendPendingRequest()
    }
    
    // MARK: - Replies
    func requestRepliesForComment(_ comment: ResponseAPIContentId, inPost post: ResponseAPIContentId, offset: UInt, limit: UInt) -> Single<[ResponseAPIContentGetComment]>
    {
        RequestsManager.shared.pendingRequests.forEach {request in
            switch request {
            case .replyToComment(let parentComment, let post, let block, let uploadingImage):
                guard isCurrentPost(post),
                    parentComment.contentId == comment,
                    let communCode = post.community?.communityId else
                {return}
                
                let authorId = parentComment.contentId.userId
                let parentCommentPermlink = parentComment.contentId.permlink
                
                BlockchainManager.instance.createMessage(
                    isComment: true,
                    parentPost: post,
                    isReplying: true,
                    parentComment: parentComment,
                    communCode: communCode,
                    parentAuthor: authorId,
                    parentPermlink: parentCommentPermlink,
                    block: block,
                    uploadingImage: uploadingImage
                ).subscribe().disposed(by: disposeBag)
                RequestsManager.shared.pendingRequests.removeAll(request)
            default:
                return
            }
        }
        
        return RestAPIManager.instance.getRepliesForComment(
            forPost: post,
            parentComment: comment,
            offset: offset,
            limit: limit,
            authorizationRequired: filter.authorizationRequired
        )
            .map {$0.items ?? []}
    }
    
    // MARK: - for grouping comments
    private func groupComments(_ comments: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        guard comments.count > 0 else {return []}

        // result array
        let result = comments.filter {$0.parents.comment == nil}
            .reduce([GroupedComment]()) { (result, comment) -> [GroupedComment] in
            return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: comments))]
        }

        return flat(result)
    }
    
    private func flat(_ array: [GroupedComment]) -> [ResponseAPIContentGetComment] {
        var myArray = [ResponseAPIContentGetComment]()
        for element in array {
            myArray.append(element.comment)
            let result = flat(element.replies)
            for i in result {
                myArray.append(i)
            }
        }
        return myArray
    }

    private func getChildForComment(_ comment: ResponseAPIContentGetComment, in source: [ResponseAPIContentGetComment]) -> [GroupedComment] {
        var result = [GroupedComment]()

        // filter child
        guard maxNestedLevel > 0 else {
            return result
        }
        
        let childComments = source
            .filter {$0.parents.comment?.permlink == comment.contentId.permlink && $0.parents.comment?.userId == comment.contentId.userId}

        if childComments.count > 0 {
            // append child
            result = childComments.reduce([GroupedComment](), { (result, comment) -> [GroupedComment] in
                return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: source))]
            })
        }

        return result
    }
    
    // MARK: - Donations
    func loadDonations(forComments comments: [ResponseAPIContentGetComment]) {
        if comments.count > 0 {
            let splitedComments = comments.prefix(20)
            
            let contentIds = splitedComments.map { RequestAPIContentId(responseAPI: $0.contentId) }
            RestAPIManager.instance.getDonationsBulk(posts: contentIds)
                .map {$0.items}
                .subscribe(onSuccess: { donations in
                    self.showDonations(donations)
                })
                .disposed(by: disposeBag)
            
            if comments.count > 20 {
                loadDonations(forComments: Array(comments.suffix(from: 20)))
            }
        }
    }
    
    private func showDonations(_ donations: [ResponseAPIWalletGetDonationsBulkItem]) {
        for var comment in items.value {
            if let donations = donations.first(where: {$0.contentId.userId == comment.contentId.userId && $0.contentId.permlink == comment.contentId.permlink && $0.contentId.communityId == comment.contentId.communityId})
            {
                comment.donations = donations
                comment.notifyChanged()
            }
            if let children = comment.children
            {
                // find in children
                for var child in children {
                    if let donations = donations.first(where: {$0.contentId.userId == child.contentId.userId && $0.contentId.permlink == child.contentId.permlink && $0.contentId.communityId == child.contentId.communityId})
                    {
                        child.donations = donations
                        child.notifyChanged()
                    }
                }
            }
        }
    }
    
    // MARK: - Send pending request
    private func sendPendingRequest() {
        // like or dislike
        var completedRequests = [RequestsManager.Request]()
        RequestsManager.shared.pendingRequests.forEach {request in
            switch request {
            case .toggleLikeComment(let comment, let dislike):
                let operation = dislike ? comment.downVote() : comment.upVote()
                operation.subscribe().disposed(by: disposeBag)
                completedRequests.append(request)
            case .newComment(let post, let block, let uploadingImage):
                if isCurrentPost(post),
                    let communCode = post.community?.communityId,
                    let authorId = post.author?.userId
                {
                    let postPermlink = post.contentId.permlink
                    BlockchainManager.instance.createMessage(
                        isComment: true,
                        parentPost: post,
                        communCode: communCode,
                        parentAuthor: authorId,
                        parentPermlink: postPermlink,
                        block: block,
                        uploadingImage: uploadingImage
                    ).subscribe().disposed(by: disposeBag)
                    completedRequests.append(request)
                }
                return
            default:
                return
            }
        }
        
        completedRequests.forEach {RequestsManager.shared.pendingRequests.removeAll($0)}
    }
    
    private func isCurrentPost(_ post: ResponseAPIContentGetPost) -> Bool {
        post.contentId.userId == filter.userId &&
        post.contentId.communityId == filter.communityId &&
        post.contentId.permlink == filter.permlink
    }
}
