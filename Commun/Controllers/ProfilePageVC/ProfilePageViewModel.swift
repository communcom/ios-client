//
//  ProfileViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa
import RxSwift

class ProfilePageViewModel {
    // MARK: - Nested type
    enum LoadingState {
        case loading
        case finished
        case error(error: Error)
    }
    
    // MARK: - Properties
    // userId for non-current user
    var userId: String? {
        didSet {
            if userId == Config.currentUser?.id {
                userId = nil
            }
        }
    }
    var isMyProfile: Bool {
        return userId == nil
    }
    let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    let profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let segmentedItem = BehaviorRelay<ProfilePageSegmentioItem>(value: .posts)
    let postsVM: PostsViewModel
    let commentsVM: CommentsViewModel
    
    public let profileLoadingState = BehaviorRelay<LoadingState>(value: .loading)
    public let listLoadingState = BehaviorRelay<ListFetcherState>(value: .loading(false))
    
    var items: Observable<[AnyObject?]> {
        return Observable.combineLatest(commentsVM.items, postsVM.items)
            .skip(1)
            .map {items -> [AnyObject?] in
                if self.segmentedItem.value == .comments {
                    if items.0.count == 0 {return [nil]}
                    return items.0 as [AnyObject?]
                }
                if items.1.count == 0 {return [nil]}
                return items.1 as [AnyObject?]
            }
    }
    
    // MARK: - Methods
    init(userId: String?) {
        self.userId = userId
        self.postsVM = PostsViewModel(
            filter: PostsListFetcher.Filter(
                feedTypeMode: .byUser,
                feedType: .timeDesc,
                sortType: .all,
                userId: userId))
        
        self.commentsVM = CommentsViewModel(
            filter: CommentsListFetcher.Filter(
                userId: userId,
                type: .user))
        
        loadProfile()
        bind()
    }
    
    // MARK: - For profile view
    func loadProfile() {
        NetworkService.shared.getUserProfile(userId: userId)
            .do(onSuccess: { (profile) in
                self.profileLoadingState.accept(.finished)
            }, onError: { (error) in
                self.profileLoadingState.accept(.error(error: error))
            }, onSubscribe: {
                self.profileLoadingState.accept(.loading)
            })
            .subscribe(onSuccess: { (profile) in
                self.profile.accept(profile)
            })
            .disposed(by: disposeBag)
    }
    
    func bind() {
        Observable.merge(postsVM.state.asObservable(), commentsVM.state.asObservable())
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
    }
    
    func reload() {
        // reload profile
        profile.accept(nil)
        
        // reload profile
        loadProfile()
    }
    
    func fetchNext() {
        switch segmentedItem.value {
        case .posts:
            postsVM.fetchNext()
        case .comments:
            commentsVM.fetchNext()
        }
    }
}
