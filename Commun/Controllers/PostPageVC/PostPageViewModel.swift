//
//  PostPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class PostPageViewModel: CommentsListController, ListViewModelType {
    // MARK: - type
    struct GroupedComment {
        var comment: ResponseAPIContentGetComment
        var replies = [GroupedComment]()
    }
    
    // MARK: - Handlers
    var loadingHandler: (() -> Void)?
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    var fetchNextCompleted: (() -> Void)?
    
    // MARK: - Inputs
    var postForRequest: ResponseAPIContentGetPost?
    var permlink: String?
    var userId: String?
    
    // MARK: - Objects
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    // comments
    var items = BehaviorRelay<[ResponseAPIContentGetComment]>(value: [])
    
    let disposeBag = DisposeBag()
    let fetcher = CommentsFetcher(filter: CommentsFetcher.Filter(type: .post))
    
    // MARK: - Methods
    init() {
        observeCommentChange()
        
        post.subscribe(onNext: { (post) in
            guard let post = post else {return}
            let permLink = post.contentId.permlink
            let userId = post.contentId.userId
            // Configure fetcher
            self.fetcher.filter.communityId = post.community.communityId
            self.fetcher.filter.permlink = permLink
            self.fetcher.filter.userId = userId
            
            self.reload()
        })
        .disposed(by: disposeBag)
    }
    
    func loadPost() {
        let permLink = postForRequest?.contentId.permlink ?? permlink ?? ""
        
        // Bind post
        NetworkService.shared.getPost(withPermLink: permLink)
            .catchError({ (error) -> Single<ResponseAPIContentGetPost> in
                if let post = self.postForRequest {
                    return .just(post)
                }
                throw error
            })
            .asObservable()
            .bind(to: post)
            .disposed(by: disposeBag)
        
        
    }
    
    func fetchNext() {
        loadingHandler?()
        fetcher.fetchNext()
            .do(onError: {error in
                self.fetchNextErrorHandler?(error)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: {[weak self] (list) in
                guard let strongSelf = self else {return}
                
                if list.count > 0 {
                    // get unique items
                    var newList = list.filter {!strongSelf.items.value.contains($0)}
                    guard newList.count > 0 else {return}
                    
                    // add last
                    newList = strongSelf.items.value + newList
                    
                    // sort
//                    newList = strongSelf.sortComments(newList)
                    
                    // resign
                    strongSelf.items.accept(newList)
                    strongSelf.fetchNextCompleted?()
                }
                
                if strongSelf.fetcher.reachedTheEnd {
                    strongSelf.listEndedHandler?()
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        items.accept([])
        fetcher.reset()
        fetchNext()
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
}
