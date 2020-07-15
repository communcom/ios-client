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
    lazy var ruleRowHeights = [String: CGFloat]()
    
    // MARK: - Objects
    var community: BehaviorRelay<ResponseAPIContentGetCommunity?> {
        return profile
    }
    let segmentedItem = BehaviorRelay<SegmentioItem>(value: .posts)
    
    lazy var postsVM = PostsViewModel(filter: PostsListFetcher.Filter(authorizationRequired: authorizationRequired, type: .community, sortBy: .time, timeframe: .all, communityId: communityId, communityAlias: communityAlias))
    lazy var leadsVM = LeadersViewModel(communityId: communityId, communityAlias: communityAlias, authorizationRequired: authorizationRequired)
    
    lazy var aboutSubject = PublishSubject<String?>()
    lazy var rules = BehaviorRelay<[ResponseAPIContentGetCommunityRule]>(value: [])
    
    // MARK: - Initializers
    init(communityId: String?, authorizationRequired: Bool = true) {
        super.init(profileId: communityId, authorizationRequired: authorizationRequired)
    }
    
    init(communityAlias: String, authorizationRequired: Bool = true) {
        self.communityAlias = communityAlias
        super.init(profileId: nil, authorizationRequired: authorizationRequired)
    }
    
    // MARK: - Methods
    override var loadProfileRequest: Single<ResponseAPIContentGetCommunity> {
        if let alias = communityAlias {
            return RestAPIManager.instance.getCommunity(alias: alias, authorizationRequired: authorizationRequired)
        }
       
        return RestAPIManager.instance.getCommunity(id: communityId ?? "", authorizationRequired: authorizationRequired)
    }
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        Observable.merge(postsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .posts}, leadsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .leads})
    }
    
    var walletGetBuyPriceRequest: Single<ResponseAPIWalletGetPrice> {
        return RestAPIManager.instance.getBuyPrice(symbol: communityId ?? communityAlias?.uppercased() ?? "CMN", quantity: "1 CMN", authorizationRequired: authorizationRequired)
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
                    self.rules.accept(self.rules.value)
                    if self.rules.value.isEmpty {
                        self.listLoadingState.accept(.listEmpty)
                    } else {
                        self.listLoadingState.accept(.listEnded)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        Observable.merge(
            postsVM.items.map {$0 as [Any]}.skip(1),
            leadsVM.items.map {$0 as [Any]}.skip(1),
            aboutSubject.map {$0 != nil ? [$0!] as [Any]: [Any]()},
            rules.map {$0 as [Any]}
        )
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
        
        profile
            .map {$0?.rules ?? []}
            .bind(to: rules)
            .disposed(by: disposeBag)
        
        // Rule changed (ex: isExpanded)
        ResponseAPIContentGetCommunityRule
            .observeItemChanged()
            .subscribe(onNext: { rule in
                var rules = self.rules.value
                if let index = rules.firstIndex(where: {$0.identity == rule.identity})
                {
                    if rule.isExpanded != rules[index].isExpanded {
                        self.ruleRowHeights.removeValue(forKey: rule.identity)
                    }
                    rules[index] = rule
                    self.rules.accept(rules)
                }
            })
            .disposed(by: disposeBag)
        
        // Update friends when user follow someone
        ResponseAPIContentGetProfile.observeProfileFollowed()
            .filter {profile in
                self.community.value?.friends?.contains(where: {$0.identity == profile.identity}) == false
            }
            .subscribe(onNext: { [weak self] (followedProfile) in
                guard let strongSelf = self,
                    var community = strongSelf.community.value
                else {return}
                community.friends?.append(followedProfile)
                strongSelf.community.accept(community)
            })
            .disposed(by: disposeBag)
    }
    
    override func reload() {
        switch segmentedItem.value {
        case .posts:
            postsVM.reload()
        case .leads:
            leadsVM.reload()
        default:
            break
        }
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
}
