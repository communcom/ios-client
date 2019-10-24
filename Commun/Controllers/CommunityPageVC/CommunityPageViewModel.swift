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
    
    #warning("fix later")
    lazy var leadsVM = PublishSubject<[String]>()
    
    lazy var aboutSubject = PublishSubject<String>()
    lazy var rulesSubject = PublishSubject<[String]>()
    
    var items: Observable<[Any?]> {
        #warning("combine more")
        let posts         = postsVM.items.map {$0.count == 0 ? [nil] : $0 as [Any?]}.skip(1)
        let leads         = leadsVM.map {$0.count == 0 ? [nil] : $0 as [Any?]}.skip(1)
        let about         = aboutSubject.map {[$0] as [Any?]}
        let rules         = rulesSubject.map {$0 as [Any?]}
        return Observable.merge(posts, leads, about, rules)
            .skip(1)
    }
    
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
        #warning("add leadsVM")
        Observable.merge(postsVM.state.asObservable())
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
                    #warning("add leadsVM")
                    self.leadsVM.onNext([])
                    self.listLoadingState.accept(.listEnded)
                case .about:
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
    }
    
    func reload() {
        // reload community
        community.accept(nil)
        
        // retrieve
        loadCommunity()
    }
    
    func fetchNext() {
        #warning("add leadsVM")
        switch segmentedItem.value {
        case .posts:
            postsVM.fetchNext()
        default:
            return
        }
    }
}
