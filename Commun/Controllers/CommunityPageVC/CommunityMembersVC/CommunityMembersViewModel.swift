//
//  CommunityMembersViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

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
    lazy var friendsVM      = BehaviorRelay<[ResponseAPIContentResolveProfile]>(value: community.friends ?? [])
    lazy var subscribersVM  = SubscribersViewModel(communityId: community.communityId)
    
    // MARK: - Initialzers
    init(community: ResponseAPIContentGetCommunity, starterSegmentedItem: SegmentedItem = .all) {
        self.community = community
        self.starterSegmentedItem = starterSegmentedItem
        super.init()
        defer {
            bind()
            fetchNext()
        }
    }
    
    // MARK: - Methods
    func bind() {
        // segmented item change
        segmentedItem
            .subscribe(onNext: { [weak self] (item) in
                self?.reload()
            })
            .disposed(by: disposeBag)
        
        // Loading state
        Observable.merge(
            leadersVM.state.asObservable().filter {_ in self.segmentedItem.value == .leaders},
            subscribersVM.state.asObservable().filter {_ in self.segmentedItem.value == .all}
        )
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                switch (lhs, rhs) {
                case (.loading(let isLoading1), .loading(let isLoading2)):
                    return isLoading1 == isLoading2
                case (.listEnded, .listEnded):
                    return true
                default:
                    return false
                }
            }
            .bind(to: listLoadingState)
            .disposed(by: disposeBag)
    }
    
    func reload() {
        if segmentedItem.value == .all || segmentedItem.value == .leaders {
            leadersVM.reload()
        }
        
        if segmentedItem.value == .all {
            subscribersVM.reload()
        }
    }
    
    func fetchNext(forceRetry: Bool = false) {
        switch segmentedItem.value {
        case .all:
            leadersVM.fetchNext(forceRetry: forceRetry)
        case .leaders:
            leadersVM.fetchNext(forceRetry: forceRetry)
        case .friends:
            break
        }
    }
}
