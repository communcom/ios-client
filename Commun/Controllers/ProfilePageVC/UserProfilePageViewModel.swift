//
//  UserProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class UserProfilePageViewModel: ProfileViewModel<ResponseAPIContentGetProfile> {
    // MARK: - Nested type
    enum SegmentioItem: String, CaseIterable {
        case posts = "posts"
        case comments = "comments"
    }
    
    // MARK: - Objects
    let segmentedItem = BehaviorRelay<SegmentioItem>(value: .posts)
    
    lazy var postsVM = PostsViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .byUser, feedType: .timeDesc, sortType: .all, userId: profileId), prefetch: profileId != nil)
    lazy var commentsVM = CommentsViewModel(filter: CommentsListFetcher.Filter(type: .user, userId: profileId), prefetch: profileId != nil)
    lazy var highlightCommunities = BehaviorRelay<[ResponseAPIContentGetCommunity]>(value: [])
    
    var username: String?
    
    // MARK: - Initializers
    init(userId: String? = nil, username: String? = nil) {
        self.username = username
        super.init(profileId: userId)
    }
    
    // MARK: - Methods
    override var loadProfileRequest: Single<ResponseAPIContentGetProfile> {
        RestAPIManager.instance.getProfile(user: profileId ?? username)
    }
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        Observable.merge(postsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .posts}, commentsVM.state.asObservable().filter {[weak self] _ in self?.segmentedItem.value == .comments})
    }
    
    override func loadProfile() {
        super.loadProfile()
        
        // if username was parsing, then wait for loading user, then fetch posts, comments
        if profileId == nil {
            profile
                .filter {$0?.userId != nil}
                .map {$0!.userId}
                .take(1)
                .asSingle()
                .subscribe(onSuccess: { (userId) in
                    self.profileId = userId
                    (self.postsVM.fetcher as! PostsListFetcher).filter.userId = userId
                    (self.commentsVM.fetcher as! CommentsListFetcher).filter.userId = userId
                    self.postsVM.fetchNext()
                    self.commentsVM.fetchNext()
                })
                .disposed(by: disposeBag)
        }
    }
    
    override func bind() {
        super.bind()        
        segmentedItem
            .filter {_ in self.profile.value != nil}
            .subscribe(onNext: { (item) in
                switch item {
                case .posts:
                    self.postsVM.reload()
                case .comments:
                    self.commentsVM.reload()
                }
            })
            .disposed(by: disposeBag)
        
        let posts = postsVM.items.map {$0 as [Any]}.skip(1)
        let comments = commentsVM.items.map { $0 as [Any] }.skip(1)

        Observable.merge(posts, comments)
            .filter { (items) -> Bool in
                if items is [ResponseAPIContentGetPost] && self.segmentedItem.value == .posts {
                    return true
                }
                
                if items is [ResponseAPIContentGetComment] && self.segmentedItem.value == .comments {
                    return true
                }
                  
                return false
            }
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)
        
        bindHighlightCommunities()
    }
    
    func bindHighlightCommunities() {
        profile
            .filter {$0?.highlightCommunities != nil}
            .map {$0!.highlightCommunities!}
            .take(1)
            .bind(to: highlightCommunities)
            .disposed(by: disposeBag)
    }
    
    override func reload() {
        postsVM.fetcher.reset()
        commentsVM.fetcher.reset()
        super.reload()
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        super.fetchNext(forceRetry: forceRetry)
        
        switch segmentedItem.value {
        case .posts:
            postsVM.fetchNext(forceRetry: forceRetry)
        default:
            commentsVM.fetchNext(forceRetry: forceRetry)
        }
    }
}
