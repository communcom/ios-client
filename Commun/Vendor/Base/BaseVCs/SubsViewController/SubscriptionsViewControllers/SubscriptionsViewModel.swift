//
//  SubscriptionsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscriptionsViewModel: ListViewModel<ResponseAPIContentGetSubscriptionsItem> {
    // MARK: - Singleton
    static var ofCurrentUserTypeUser = SubscriptionsViewModel(type: .user)
    static var ofCurrentUserTypeCommunity = SubscriptionsViewModel(type: .community)
    
    let type: GetSubscriptionsType
    
    lazy var searchVM: SearchViewModel = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        return SearchViewModel(fetcher: fetcher)
    }()
    
    init(userId: String? = nil, type: GetSubscriptionsType, prefetch: Bool = true) {
        var userId = userId
        if userId == nil {
            userId = Config.currentUser?.id ?? ""
        }
        let fetcher = SubscriptionsListFetcher(userId: userId!, type: type)
        self.type = type
        super.init(fetcher: fetcher)
        
        defer {
            switch type {
            case .user:
                (searchVM.fetcher as! SearchListFetcher).entitySearchEntity = .profiles
            case .community:
                (searchVM.fetcher as! SearchListFetcher).entitySearchEntity = .communities
            }
            
            if prefetch {
                fetchNext()
            }
            
            observeProfileBlocked()
            if userId == Config.currentUser?.id {
                observeUserFollowed()
            }
        }
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        if searchVM.isQueryEmpty {
            super.fetchNext(forceRetry: forceRetry)
        } else {
            searchVM.fetchNext(forceRetry: forceRetry)
        }
    }
    
    override func reload(clearResult: Bool = true) {
        if searchVM.isQueryEmpty {
            super.reload(clearResult: clearResult)
        } else {
            searchVM.reload(clearResult: clearResult)
        }
    }
    
    func update() {
        reload(clearResult: false)
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetProfile.observeItemDeleted()
            .subscribe(onNext: { (deletedUser) in
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.user(deletedUser))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemDeleted()
            .subscribe(onNext: { (deletedCommunity) in
                self.deleteItem(ResponseAPIContentGetSubscriptionsItem.community(deletedCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemChange() {
        ResponseAPIContentGetProfile.observeItemChanged()
            .subscribe(onNext: { (newItem) in
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.user(newItem))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: {newCommunity in
                self.updateItem(ResponseAPIContentGetSubscriptionsItem.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    func observeProfileBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                self.deleteItemWithIdentity(blockedProfile.identity)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                self.deleteItemWithIdentity(blockedProfile.identity)
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserFollowed() {
        // if current user follow someone
        ResponseAPIContentGetProfile.observeProfileFollowed()
            .filter {profile in
                !self.items.value.contains(where: {$0.identity == profile.identity})
            }
            .subscribe(onNext: { (followedProfile) in
                var newItems = [ResponseAPIContentGetSubscriptionsItem.user(followedProfile)]
                newItems.joinUnique(self.items.value)
                self.items.accept(newItems)
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserUnfollowed() {
        // if current user unfollow someone
        ResponseAPIContentGetProfile.observeProfileUnfollowed()
            .filter {profile in
                self.items.value.contains(where: {$0.identity == profile.identity})
            }
            .subscribe(onNext: { (unfollowedProfile) in
                self.deleteItemWithIdentity(unfollowedProfile.identity)
            })
            .disposed(by: disposeBag)
    }
}
