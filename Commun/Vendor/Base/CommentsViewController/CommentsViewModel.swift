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
    
    override func updateItem(_ updatedItem: ResponseAPIContentGetComment) {
        var newItems = fetcher.items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        let oldItem = newItems[index]
        var updatedItem = updatedItem
        let newChildren = updatedItem.children?.filter({ (newComment) -> Bool in
            !(oldItem.children ?? []).contains(where: {newComment.identity == $0.identity})
        })
        updatedItem.children = ((oldItem.children ?? []) + (newChildren ?? []))
        newItems[index] = updatedItem
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(newItems)
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - Child comments
    /// childFetcher for each section (Int) for retrieving child comments
    var childFetchers = [Int: CommentsListFetcher]()
}
