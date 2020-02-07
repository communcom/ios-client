//
//  CommunityViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift
import SwiftyJSON

class CommunityPageViewModel: ProfileViewModel<ResponseAPIContentGetCommunity> {
    // MARK: - Nested type
    enum SegmentioItem: String, CaseIterable {
        case posts = "posts"
        case leads = "leads"
        case about = "about"
        case rules = "rules"
    }
    
    // MARK: - Input
    var communityForRequest: ResponseAPIContentGetCommunity? {
        return profileForRequest
    }
    var communityId: String? {
        return profileId
    }
    
    var communityAlias: String?
    
    // MARK: - Objects
    var community: BehaviorRelay<ResponseAPIContentGetCommunity?> {
        return profile
    }
    let segmentedItem = BehaviorRelay<SegmentioItem>(value: .posts)
    
    lazy var postsVM: PostsViewModel = PostsViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: communityId, communityAlias: communityAlias))
    lazy var leadsVM = LeadersViewModel(communityId: communityId, communityAlias: communityAlias)
    
    lazy var aboutSubject = PublishSubject<String?>()
    lazy var rulesSubject = PublishSubject<[ResponseAPIContentGetCommunityRule]>()
    
    // MARK: - Initializers
    convenience init(community: ResponseAPIContentGetCommunity?) {
        self.init()
        self.profileForRequest = community
        self.init(profileId: community?.communityId)
    }
    
    convenience init(communityId: String?) {
        self.init(profileId: communityId)
    }
    
    convenience init(communityAlias: String) {
        self.init()
        self.communityAlias = communityAlias
        
        defer {
            loadProfile()
            bind()
        }
    }
    
    // MARK: - Methods
    override var loadProfileRequest: Single<ResponseAPIContentGetCommunity> {
        if let alias = communityAlias {
            return RestAPIManager.instance.getCommunity(alias: alias)
        }
        return RestAPIManager.instance.getCommunity(id: communityId ?? "")
    }
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        Observable.merge(postsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .posts}, leadsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .leads})
    }
    
    var walletGetBuyPriceRequest: Single<ResponseAPIWalletGetPrice> {
        return RestAPIManager.instance.getBuyPrice(symbol: communityId ?? "CMN", quantity: "10 CMN")
    }

    override func bind() {
        super.bind()
        
        segmentedItem
            .filter {_ in self.community.value != nil}
            .subscribe(onNext: { (item) in
                switch item {
                case .posts:
                    self.postsVM.reload()
                case .leads:
                    self.leadsVM.reload()
                case .about:
                    if let description = self.community.value?.description,
                        !description.isEmpty {
                        self.aboutSubject.onNext(description)
                        self.listLoadingState.accept(.listEnded)
                        return
                    }
                    self.aboutSubject.onNext(nil)
                    self.listLoadingState.accept(.listEmpty)
                case .rules:
                    let rules = self.community.value?.rules ?? [ResponseAPIContentGetCommunityRule]()
                    self.rulesSubject.onNext(rules)
                    if rules.isEmpty {
                        self.listLoadingState.accept(.listEmpty)
                    } else {
                        self.listLoadingState.accept(.listEnded)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        let posts         = postsVM.items.map {$0 as [Any]}.skip(1)
        let leads         = leadsVM.items.map {$0 as [Any]}.skip(1)
        let about         = aboutSubject.map {$0 != nil ? [$0!] as [Any]: [Any]()}
        let rules         = rulesSubject.map {$0 as [Any]}
        Observable.merge(posts, leads, about, rules)
            .filter({ items -> Bool in
                if items is [ResponseAPIContentGetPost] && self.segmentedItem.value == .posts {
                    return true
                }
                if items is [ResponseAPIContentGetLeader] && self.segmentedItem.value == .leads {
                    return true
                }
                if items is [String] && self.segmentedItem.value == .about {
                    return true
                }
                if items is [ResponseAPIContentGetCommunityRule] && self.segmentedItem.value == .rules {
                    return true
                }
                return false
            })
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)
    }
    
    override func reload() {
        postsVM.fetcher.reset()
        leadsVM.fetcher.reset()
        super.reload()
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        super.fetchNext(forceRetry: forceRetry)
        switch segmentedItem.value {
        case .posts:
            postsVM.fetchNext(forceRetry: forceRetry)
        case .leads:
            leadsVM.fetchNext(forceRetry: forceRetry)
        default:
            return
        }
    }
    
    func loadBalances(byUserID userID: String) -> Single<[ResponseAPIWalletGetBalance]> {
        return RestAPIManager.instance.getBalance(userId: userID).map{ $0.balances }
    }
}
