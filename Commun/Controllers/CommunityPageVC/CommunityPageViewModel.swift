//
//  CommunityViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class CommunityPageViewModel {
    // MARK: - Nested type
    enum LoadingState {
        case loading
        case finished
        case error(error: Error)
    }
    
    enum SegmentioItem: String, CaseIterable {
        case posts = "posts"
        case leads = "leads"
        case about = "about"
        case rules = "rules"
    }
    
    // MARK: - Input
    var communityForRequest: ResponseAPIContentGetCommunity?
    var communityId: String?
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Objects
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let listLoadingState = BehaviorRelay<ListFetcherState>(value: .loading(false))
    
    let community = BehaviorRelay<ResponseAPIContentGetCommunity?>(value: nil)
    let segmentedItem = BehaviorRelay<SegmentioItem>(value: .posts)
    
    lazy var postsVM: PostsViewModel = PostsViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: communityId))
    lazy var leadsVM = LeadersViewModel(communityId: communityId ?? "")
    
    lazy var aboutSubject = PublishSubject<String>()
    lazy var rulesSubject = PublishSubject<[String]>()
    
    let items = BehaviorRelay<[Any]>(value: [])
    
    // MARK: - Initializers
    convenience init(community: ResponseAPIContentGetCommunity?) {
        self.init()
        self.communityForRequest = community
        self.communityId = community?.communityId
        
        defer {
            loadCommunity()
        }
    }
    
    convenience init(communityId: String?) {
        self.init()
        self.communityId = communityId
        
        defer {
            loadCommunity()
            bind()
        }
    }
    
    // MARK: - Methods
    func loadCommunity() {
        RestAPIManager.instance.getCommunity(id: communityId ?? "")
            .map {$0 as ResponseAPIContentGetCommunity?}
            .do(onSuccess: { (profile) in
                self.loadingState.accept(.finished)
            }, onError: { (error) in
                self.loadingState.accept(.error(error: error))
            }, onSubscribe: {
                self.loadingState.accept(.loading)
            })
            .asDriver(onErrorJustReturn: communityForRequest)
            .drive(community)
            .disposed(by: disposeBag)
    }
    
    func bind() {
        Observable.merge(postsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .posts}, leadsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .leads})
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
        
        segmentedItem
            .filter {_ in self.community.value != nil}
            .subscribe(onNext: { (item) in
                switch item {
                case .posts:
                    self.postsVM.reload()
                case .leads:
                    self.leadsVM.reload()
                case .about:
                    #warning("fix about and rules")
                    self.aboutSubject.onNext("Binance is a blockchain ecosystem comprised of Exchange, Labs, Launchpad, and Info. Binance Exchange is one of the fastest growing and most popular cryptocurrency exchanges in the world. Founded by a team of fintech and crypto experts — it is capable of processing more than 1.4 million orders per second, making it one of the fastest exchanges in the world. The platform focuses on security, robustness, and execution speed — attracting enthusiasts and professional traders alike.")
                    self.listLoadingState.accept(.listEnded)
                case .rules:
                    self.rulesSubject.onNext([
                        "1. Content must target the Overwatch aud...",
                        "2. Content should be Safe for Work"
                    ])
                    self.listLoadingState.accept(.listEnded)
                }
            })
            .disposed(by: disposeBag)
        
        let posts         = postsVM.items.map {$0 as [Any]}.skip(1)
        let leads         = leadsVM.items.map {$0 as [Any]}.skip(1)
        let about         = aboutSubject.map {[$0] as [Any]}
        let rules         = rulesSubject.map {$0 as [Any]}
        Observable.merge(posts, leads, about, rules)
            .filter({ items -> Bool in
                if items is [ResponseAPIContentGetPost] && self.segmentedItem.value == .posts {
                    return true
                }
                if items is [ResponseAPIContentGetLeader] && self.segmentedItem.value == .leads {
                    return true
                }
                #warning("fix later")
                if items is [String] && self.segmentedItem.value == .about {
                    return true
                }
                if items is [String] && self.segmentedItem.value == .rules {
                    return true
                }
                return false
            })
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)
    }
    
    func reload() {
        // reload community
        community.accept(nil)
        
        // retrieve
        loadCommunity()
    }
    
    func fetchNext(forceRetry: Bool = false) {
        switch segmentedItem.value {
        case .posts:
            postsVM.fetchNext(forceRetry: forceRetry)
        case .leads:
            leadsVM.fetchNext(forceRetry: forceRetry)
        default:
            return
        }
    }
}
