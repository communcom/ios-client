//
//  ProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class ProfilePageViewModel: ListViewModelType {
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
    
    // Subjects
    let profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let items = BehaviorRelay<[Decodable]>(value: [])
    let segmentedItem = BehaviorRelay<ProfilePageSegmentioItem>(value: .posts)
    
    // Fetcher
    var itemsFetcher: AnyObject!
    
    // Bag
    let bag = DisposeBag()
    
    // Handlers
    var loadingHandler: (() -> Void)?
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    
    var profileLoadingHandler: ((Bool) -> Void)?
    var profileFetchingErrorHandler: ((Error?) -> Void)?
    
    init(userId: String?) {
        self.userId = userId
        loadProfile()
        bindElements()
    }
    
    func bindElements() {
        // Retrieve items after segemented changes
        segmentedItem
            .filter {_ in self.profile.value != nil}
            .flatMapLatest {item -> Maybe<[Decodable]> in
                // Re-create fetcher
                switch item {
                case .posts:
                    let customFetcher = PostsFetcher(filter: PostsFetcher.Filter(feedTypeMode: .byUser, feedType: .timeDesc, sortType: .all))
                    customFetcher.userId = self.userId
                    self.itemsFetcher = customFetcher
                case .comments:
                    let customFetcher = CommentsFetcher()
                    customFetcher.userId = self.userId
                    self.itemsFetcher = customFetcher
                }
                // Empty table
                self.items.accept([])
                
                return self.fetchNextMaybe()
            }
            .asDriver(onErrorJustReturn: [])
            .map {self.items.value + $0}
            .drive(items)
            .disposed(by: bag)
    }
    
    func reload() {
        // reload profile
        profile.accept(nil)
        
        // reload profile
        loadProfile()
    }
    
    // MARK: - For profile view
    func loadProfile() {
        NetworkService.shared.getUserProfile(userId: userId)
            .do(onSubscribe: {
                self.profileLoadingHandler?(true)
                self.profileFetchingErrorHandler?(nil)
            })
            .subscribe(onSuccess: { (profile) in
                self.profileLoadingHandler?(false)
                self.profileFetchingErrorHandler?(nil)
                self.profile.accept(profile)
            }) { (error) in
                self.profileLoadingHandler?(false)
                self.profileFetchingErrorHandler?(error)
            }
            .disposed(by: bag)
    }
    
    // MARK: - For items in tableView
    func fetchNext() {
        loadingHandler?()
        fetchNextMaybe()
            .do(onError: {error in
                self.fetchNextErrorHandler?(error)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { (list) in
                if list.count > 0 {
                    self.items.accept(self.items.value + list)
                }
                
                switch self.segmentedItem.value {
                case .posts:
                    guard let fetcher = self.itemsFetcher as? PostsFetcher else {return}
                    if (fetcher.reachedTheEnd) {
                        self.listEndedHandler?()
                    }
                case .comments:
                    guard let fetcher = self.itemsFetcher as? CommentsFetcher else {return}
                    if (fetcher.reachedTheEnd) {
                        self.listEndedHandler?()
                    }
                }
                
            })
            .disposed(by: bag)
    }
    
    private func fetchNextMaybe() -> Maybe<[Decodable]> {
        let single: Maybe<[Decodable]>
        switch segmentedItem.value {
        case .posts:
            guard let fetcher = itemsFetcher as? PostsFetcher else {return .never()}
            single = fetcher.fetchNext().map {$0 as [ResponseAPIContentGetPost]}
        case .comments:
            guard let fetcher = itemsFetcher as? CommentsFetcher else {return .never()}
            single = fetcher.fetchNext().map {$0 as [ResponseAPIContentGetComment]}
        }
        return single
    }
}
