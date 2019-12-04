//
//  CommentsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

class CommentsViewModel: ListViewModel<ResponseAPIContentGetComment> {
    var filter: BehaviorRelay<CommentsListFetcher.Filter>!
    
    init(
        filter: CommentsListFetcher.Filter = CommentsListFetcher.Filter(type: .user))
    {
        let fetcher = CommentsListFetcher(filter: filter)
        super.init(fetcher: fetcher)
        self.filter = BehaviorRelay<CommentsListFetcher.Filter>(value: filter)
        defer {
            bindFilter()
            observeChildrenChanged()
            observeUserBlocked()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
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
        guard let index = items.firstIndex(where: {$0.identity == parentComment.identity}) else {return}
        items[index].children = parentComment.children
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(items)
        UIView.setAnimationsEnabled(true)
    }
    
    override func updateItem(_ updatedItem: ResponseAPIContentGetComment) {
        var items = fetcher.items.value
        
        // if item is a first lever comment
        if let index = items.firstIndex(where: {$0.identity == updatedItem.identity})
        {
            let oldItem = items[index]
            var updatedItem = updatedItem
            let newChildren = updatedItem.children?.filter({ (newComment) -> Bool in
                !(oldItem.children ?? []).contains(where: {newComment.identity == $0.identity})
            })
            updatedItem.children = ((oldItem.children ?? []) + (newChildren ?? []))
            guard let newUpdatedItem = items[index].newUpdatedItem(from: updatedItem) else {return}
            items[index] = newUpdatedItem
            UIView.setAnimationsEnabled(false)
            fetcher.items.accept(items)
            UIView.setAnimationsEnabled(true)
            return
        }
        // if item is a reply
        if let commentIndex = items.firstIndex(where: { (comment) -> Bool in
            comment.children?.contains(where: {$0.identity == updatedItem.identity}) ?? false
        }) {
            if let replyIndex = items[commentIndex].children?.firstIndex(where: {$0.identity == updatedItem.identity}) {
                guard let newUpdatedItem = items[commentIndex].children?[replyIndex].newUpdatedItem(from: updatedItem) else {return}
                items[commentIndex].children?[replyIndex] = newUpdatedItem
                UIView.setAnimationsEnabled(false)
                fetcher.items.accept(items)
                UIView.setAnimationsEnabled(true)
            }
            return
        }
    }
    
    override func deleteItem(_ deletedItem: ResponseAPIContentGetComment) {
        var items = fetcher.items.value
        
        // if item is a first lever comment
        if let index = items.firstIndex(where: {$0.identity == deletedItem.identity})
        {
            items.remove(at: index)
            UIView.setAnimationsEnabled(false)
            fetcher.items.accept(items)
            UIView.setAnimationsEnabled(true)
            return
        }
        
        // if item is a reply
        if let commentIndex = items.firstIndex(where: { (comment) -> Bool in
            comment.children?.contains(where: {$0.identity == deletedItem.identity}) ?? false
        }) {
            if let replyIndex = items[commentIndex].children?.firstIndex(where: {$0.identity == deletedItem.identity}) {
                items[commentIndex].children?.remove(at: replyIndex)
                UIView.setAnimationsEnabled(false)
                fetcher.items.accept(items)
                UIView.setAnimationsEnabled(true)
            }
        }
    }
}
