//
//  CommentsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CommentsViewModel: ListViewModel<ResponseAPIContentGetComment> {
    var filter: BehaviorRelay<CommentsListFetcher.Filter>!
    
    init(
        filter: CommentsListFetcher.Filter = CommentsListFetcher.Filter(type: .user),
        prefetch: Bool = false
    ) {
        let fetcher = CommentsListFetcher(filter: filter)
        super.init(fetcher: fetcher, prefetch: prefetch)
        self.filter = BehaviorRelay<CommentsListFetcher.Filter>(value: filter)
        defer {
            bindFilter()
            observeChildrenChanged()
            observeUserBlocked()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
            .filter {$0.communityId != nil && $0.permlink != nil && $0.userId != nil}
            .subscribe(onNext: {filter in
                self.fetcher.reset(clearResult: false)
                (self.fetcher as! CommentsListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: {_ in
                self.reload()
            })
            .disposed(by: disposeBag)
    }
    
    func changeFilter(
        sortBy: CommentSortMode? = nil,
        type: GetCommentsType? = nil,
        userId: String? = nil,
        permlink: String? = nil,
        communityId: String? = nil,
        communityAlias: String? = nil,
        parentComment: ResponseAPIContentId? = nil,
        resolveNestedComments: Bool? = nil
    ) {
        let newFilter = filter.value.newFilter(withSortBy: sortBy, type: type, userId: userId, permlink: permlink, communityId: communityId, communityAlias: communityAlias, parentComment: parentComment, resolveNestedComments: resolveNestedComments)
        if newFilter != filter.value {
            filter.accept(newFilter)
        }
    }
    
    func observeChildrenChanged() {
        ResponseAPIContentGetComment.observeEvent(
            eventName: ResponseAPIContentGetComment.childrenDidChangeEventName
        )
            .subscribe(onNext: { item in
                self.updateChildren(parentComment: item)
            })
            .disposed(by: disposeBag)
    }
    
    func updateChildren(parentComment: ResponseAPIContentGetComment) {
        var items = fetcher.items.value
        
        // if item is a first lever comment
        if let index = items.firstIndex(where: {$0.identity == parentComment.identity}) {
            items[index].children = parentComment.children
            fetcher.items.accept(items)
            return
        }
        
        // if item is a reply
        if let commentIndex = items.firstIndex(where: { (comment) -> Bool in
            comment.children?.contains(where: {$0.identity == parentComment.identity}) ?? false
        }),
            let newChildren = parentComment.children,
            !newChildren.isEmpty {
            items[commentIndex].children?.joinUnique(newChildren)
            fetcher.items.accept(items)
            return
        }
    }
    
    override func updateItem(_ updatedItem: ResponseAPIContentGetComment) {
        var items = fetcher.items.value
        
        // if item is a first lever comment
        if let index = items.firstIndex(where: {$0.identity == updatedItem.identity}) {
            let oldItem = items[index]
            var updatedItem = updatedItem
            let newChildren = updatedItem.children?.filter({ (newComment) -> Bool in
                !(oldItem.children ?? []).contains(where: {newComment.identity == $0.identity})
            })
            updatedItem.children = ((oldItem.children ?? []) + (newChildren ?? []))
            guard let newUpdatedItem = items[index].newUpdatedItem(from: updatedItem) else {return}
            if !isEqualRowHeight(cmt1: items[index], cmt2: newUpdatedItem) {
                rowHeights.removeValue(forKey: updatedItem.identity)
            }
            items[index] = newUpdatedItem
            fetcher.items.accept(items)
            return
        }
        // if item is a reply
        if let commentIndex = items.firstIndex(where: { (comment) -> Bool in
            comment.children?.contains(where: {$0.identity == updatedItem.identity}) ?? false
        }) {
            if let replyIndex = items[commentIndex].children?.firstIndex(where: {$0.identity == updatedItem.identity}) {
                guard let newUpdatedItem = items[commentIndex].children?[replyIndex].newUpdatedItem(from: updatedItem) else {return}
                if !isEqualRowHeight(cmt1: items[commentIndex].children?[replyIndex], cmt2: newUpdatedItem) {
                    rowHeights.removeValue(forKey: updatedItem.identity)
                }
                
                items[commentIndex].children?[replyIndex] = newUpdatedItem
                fetcher.items.accept(items)
            }
            return
        }
    }
    
    func isEqualRowHeight(cmt1: ResponseAPIContentGetComment?, cmt2: ResponseAPIContentGetComment?) -> Bool {
        return cmt1?.attachments.count == cmt2?.attachments.count &&
            (try? cmt1?.document?.jsonString()) == (try? cmt2?.document?.jsonString())
    }
    
    override func deleteItem(_ deletedItem: ResponseAPIContentGetComment) {
        var items = fetcher.items.value
        
        // if item is a first lever comment
        if let index = items.firstIndex(where: {$0.identity == deletedItem.identity}) {
            rowHeights.removeValue(forKey: deletedItem.identity)
            items.remove(at: index)
            fetcher.items.accept(items)
            return
        }
        
        // if item is a reply
        if let commentIndex = items.firstIndex(where: { (comment) -> Bool in
            comment.children?.contains(where: {$0.identity == deletedItem.identity}) ?? false
        }) {
            if let replyIndex = items[commentIndex].children?.firstIndex(where: {$0.identity == deletedItem.identity}) {
                rowHeights.removeValue(forKey: deletedItem.identity)
                items[commentIndex].children?.remove(at: replyIndex)
                fetcher.items.accept(items)
            }
        }
    }
}
