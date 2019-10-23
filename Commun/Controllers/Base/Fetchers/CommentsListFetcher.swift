//
//  CommentsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CommentsListFetcher: ListFetcher<ResponseAPIContentGetComment> {
    // MARK: - type
    struct GroupedComment {
       var comment: ResponseAPIContentGetComment
       var replies = [GroupedComment]()
    }
    
    // MARK: - Enums
    struct Filter: FilterType {
        var permlink: String?
        var userId: String?
        var communityId: String?
        var communityAlias: String?
        var type: GetCommentsType
    }
    
    var filter: Filter
    
    init(filter: Filter) {
        self.filter = filter
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
                        sortBy: .time,
                        offset: offset,
                        limit: 30,
                        permlink: filter.permlink ?? "",
                        communityId: filter.communityId,
                        communityAlias: filter.communityAlias
                    )
                case .user:
                    result = RestAPIManager.instance.loadUserComments(
                        offset: offset,
                        limit: 30,
                        userId: filter.userId)
                case .replies:
                    fatalError("Implementing")
                }
                
                return result
                    .map {$0.items ?? []}
    }
    
    override func join(newItems items: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        var newList = items.filter {!self.items.value.contains($0)}
        newList = self.items.value + newList
        // sort
        newList = sortComments(newList)
        return newList
    }
    
    func flat(_ array:[GroupedComment]) -> [ResponseAPIContentGetComment] {
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
    
    func sortComments(_ comments: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        guard comments.count > 0 else {return []}

        // result array
        let result = comments.filter {$0.parents.comment == nil}
            .reduce([GroupedComment]()) { (result, comment) -> [GroupedComment] in
                return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: comments))]
        }

        return flat(result)
    }

    var maxNestedLevel = 6

    func getChildForComment(_ comment: ResponseAPIContentGetComment, in source: [ResponseAPIContentGetComment]) -> [GroupedComment] {

        var result = [GroupedComment]()

        // filter child
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
}
