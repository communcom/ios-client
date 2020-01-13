//
//  CommunityMembersViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class CommunityMembersViewModel: BaseViewModel {
    // MARK: - Nested item
    enum SegmentedItem: String, CaseIterable {
        case all        = "all"
        case leaders    = "leaders"
        case friends    = "friends"
        
        static var allCases: [SegmentedItem] {
            return [.all, .leaders, .friends]
        }
        
        var index: Int {
            switch self {
            case .all:
                return 0
            case .leaders:
                return 1
            case .friends:
                return 2
            }
        }
    }
    
    // MARK: - Input
    var community: ResponseAPIContentGetCommunity
    var starterSegmentedItem: SegmentedItem
    
    // MARK: - Objects
    let listLoadingState    = BehaviorRelay<ListFetcherState>(value: .loading(false))
    lazy var segmentedItem  = BehaviorRelay<SegmentedItem>(value: starterSegmentedItem)
    lazy var leadersVM      = LeadersViewModel(communityId: community.communityId)
    lazy var friendsVM      = FriendsViewModel(friends: community.friends ?? [])
    lazy var subscribersVM  = SubscribersViewModel(communityId: community.communityId)
    let items = BehaviorRelay<[Any]>(value: [])
    
    // MARK: - Initialzers
    init(community: ResponseAPIContentGetCommunity, starterSegmentedItem: SegmentedItem = .all) {
        self.community = community
        self.starterSegmentedItem = starterSegmentedItem
        super.init()
        defer {
            bind()
        }
    }
    
    // MARK: - Methods
    func bind() {
        // segmented item change
        segmentedItem
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (_) in
                self?.reload()
            })
            .disposed(by: disposeBag)
        
        // Loading state
        Observable.merge(
            leadersVM.state.asObservable().filter {_ in self.segmentedItem.value == .leaders},
            subscribersVM.state.asObservable().filter {_ in self.segmentedItem.value == .all}
        )
            .distinctUntilChanged()
            .bind(to: listLoadingState)
            .disposed(by: disposeBag)
        
        let leaders     = leadersVM.items.map {$0 as [Any]}.skip(1)
            .filter { _ in
                self.segmentedItem.value == .leaders || self.segmentedItem.value == .all
            }
        let subscribers = subscribersVM.items.map {$0 as [Any]}.skip(1)
            .filter { _ in
                self.segmentedItem.value == .all
            }
        let friends     = friendsVM.items.map {$0 as [Any]}
            .filter {_ in
                self.segmentedItem.value == .friends
            }
        
        Observable.merge(leaders, subscribers, friends)
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)
    }
    
    func reload() {
        if segmentedItem.value == .all || segmentedItem.value == .leaders {
            leadersVM.reload()
        }
        
        if segmentedItem.value == .all {
            subscribersVM.reload()
        }
        
        if segmentedItem.value == .friends {
            let friends = friendsVM.items.value
            if !friends.isEmpty {
               friendsVM.accept(friends)
               listLoadingState.accept(.listEnded)
               return
            }
            friendsVM.accept([])
            listLoadingState.accept(.listEmpty)
        }
    }
    
    func fetchNext(forceRetry: Bool = false) {
        switch segmentedItem.value {
        case .all:
            subscribersVM.fetchNext(forceRetry: forceRetry)
        case .leaders:
            leadersVM.fetchNext(forceRetry: forceRetry)
        case .friends:
            return
        }
    }
}
