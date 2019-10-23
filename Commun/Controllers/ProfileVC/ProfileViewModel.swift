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

class ProfileViewModel {
    // MARK: - Nested type
    enum LoadingState {
        case loading
        case finished
        case error(error: Error)
    }
    
    // MARK: - Properties
    // userId for non-current user
    var userId: String? = nil {
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
    let postsVM = PostsViewModel(
        filter: PostsFetcher.Filter(
            feedTypeMode: .byUser,
            feedType: .timeDesc,
            sortType: .all))
    let commentsVM = CommentsViewModel()
    
    public let profileLoadingState = BehaviorRelay<LoadingState>(value: .loading)
    public let listLoadingState = BehaviorRelay<ListLoadingState>(value: .loading)
    
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
                case (.loading, .loading):
                    return true
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
