//
//  CommentsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

class CommentsViewModel: ListViewModel<ResponseAPIContentGetComment>, CommentsListController {
    // MARK: - type
    struct GroupedComment {
        var comment: ResponseAPIContentGetComment
        var replies = [GroupedComment]()
    }
    
    var filter: BehaviorRelay<CommentsFetcher.Filter>!
    
    convenience init(
        filter: CommentsFetcher.Filter = CommentsFetcher.Filter(type: .user))
    {
        let fetcher = CommentsFetcher(filter: filter)
        self.init(fetcher: fetcher)
        self.filter = BehaviorRelay<CommentsFetcher.Filter>(value: filter)
        
        defer {
            observeCommentChange()
        }
    }
    
    override func onItemsFetched(items: [ResponseAPIContentGetComment]) {
        if items.count > 0 {
            // get unique items
            var newList = items.filter {!self.items.value.contains($0)}
            guard newList.count > 0 else {return}
            
            // add last
            newList = self.items.value + newList
            
            // sort
//                    newList = strongSelf.sortComments(newList)
            
            // resign
            self.items.accept(newList)
        }
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
    
    //    func sortComments(_ comments: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
    //        guard comments.count > 0 else {return []}
    //
    //        // result array
    //        let result = comments.filter {$0.parents.comment == nil}
    //            .reduce([GroupedComment]()) { (result, comment) -> [GroupedComment] in
    //                return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: comments))]
    //        }
    //
    //        return flat(result)
    //    }
    //
    //    var maxNestedLevel = 6
    //
    //    func getChildForComment(_ comment: ResponseAPIContentGetComment, in source: [ResponseAPIContentGetComment]) -> [GroupedComment] {
    //
    //        var result = [GroupedComment]()
    //
    //        // filter child
    //        let childComments = source
    //            .filter {$0.parents.comment?.contentId.permlink == comment.contentId.permlink && $0.parents.comment.contentId.userId == comment.contentId.userId}
    //
    //        if childComments.count > 0 {
    //            // append child
    //            result = childComments.reduce([GroupedComment](), { (result, comment) -> [GroupedComment] in
    //                return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: source))]
    //            })
    //        }
    //
    //        return result
    //    }
}
