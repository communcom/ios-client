//
//  MyProfileBlacklistViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MyProfileBlacklistViewModel: BaseViewModel {
    // MARK: - Nested item
    enum SegmentedItem: String, CaseIterable {
        case users    = "users"
        case communities    = "communities"
        
        static var allCases: [SegmentedItem] {
            return [.users, .communities]
        }
        
        var index: Int {
            switch self {
            case .users:
                return 0
            case .communities:
                return 1
            }
        }
    }
    
    // MARK: - Objects
    let listLoadingState    = BehaviorRelay<ListFetcherState>(value: .loading(false))
    lazy var segmentedItem  = BehaviorRelay<SegmentedItem>(value: .users)
    lazy var usersVM        = BlacklistViewModel(type: .users)
    lazy var communitiesVM  = BlacklistViewModel(type: .communities)
    let items = BehaviorRelay<[ResponseAPIContentGetBlacklistItem]>(value: [])
    
    // MARK: - Initializers
    override init() {
        super.init()
        defer {
            bind()
            fetchNext(forceRetry: true)
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
            usersVM.state.asObservable().filter {_ in self.segmentedItem.value == .users},
            communitiesVM.state.asObservable().filter {_ in self.segmentedItem.value == .communities}
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
        
        // items
        usersVM.items.filter {_ in self.segmentedItem.value == .users}
            .bind(to: items)
            .disposed(by: disposeBag)
        
        communitiesVM.items.filter {_ in self.segmentedItem.value == .communities}
            .bind(to: items)
            .disposed(by: disposeBag)
    }
    
    func reload() {
        switch segmentedItem.value {
        case .users:
            usersVM.reload()
        case .communities:
            communitiesVM.reload()
        }
    }
    
    func fetchNext(forceRetry: Bool = false) {
        switch segmentedItem.value {
        case .users:
            usersVM.fetchNext(forceRetry: forceRetry)
        case .communities:
            communitiesVM.fetchNext(forceRetry: forceRetry)
        }
    }
}
