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

class ProfilePageViewModel {
    // Subjects
    let profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let items = BehaviorRelay<[Decodable]>(value: [])
    let segmentedItem = BehaviorRelay<ProfilePageSegmentioItem>(value: .posts)
    
    // Fetcher
    private var itemsFetcher: AnyObject!
    
    // Bag
    let bag = DisposeBag()
    
    init() {
        bindElements()
    }
    
    func bindElements() {
        let nonNilProfile = profile.filter {$0 != nil}
            .map {$0!}
        
        // Retrieve items after receiving profile
        nonNilProfile
            .withLatestFrom(segmentedItem)
            .flatMapLatest { (item: ProfilePageSegmentioItem) -> Single<[Decodable]> in
                // Empty table
                self.items.accept([])
                
                // Cast itemsFetcher
                switch item {
                case .posts:
                    // Reset fetcher
                    guard let fetcher = self.itemsFetcher as? PostsFetcher else {return Single.never()}
                    fetcher.reset()
                    
                    // FetchNext items
                    return fetcher.fetchNext()
                        .map {$0 as [ResponseAPIContentGetPost]}
                case .comments:
                    #warning("Fetcher for comments")
                    return Single.never()
                }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: bag)
        
        // Retrieve items after segemented changes
        segmentedItem
            .subscribe(onNext: {item in
                // Re-create fetcher
                switch item {
                case .posts:
                    let customFetcher = PostsFetcher()
                    self.itemsFetcher = customFetcher
                case .comments:
                    #warning("Fetcher for comments")
                    let customFetcher = ItemsFetcher<ResponseAPIContentGetComment>()
                    self.itemsFetcher = customFetcher
                }
                // Empty table
                self.items.accept([])
                
                // Fetch next
                self.fetchNext()
            })
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
        NetworkService.shared.getUserProfile()
            .subscribe(onSuccess: { (profile) in
                self.profile.accept(profile)
            }) { (error) in
                #warning("handle error")
                print(error)
            }
            .disposed(by: bag)
    }
    
    // MARK: - For items in tableView
    func fetchNext() {
        let single: Single<[Decodable]>
        switch segmentedItem.value {
        case .posts:
            guard let fetcher = itemsFetcher as? PostsFetcher else {return}
            single = fetcher.fetchNext().map {$0 as [ResponseAPIContentGetPost]}
        case .comments:
            #warning("Fetcher for comments")
            single = Single.never()
        }
        single
            .asDriver(onErrorJustReturn: [])
            .map {self.items.value + $0}
            .drive(items)
            .disposed(by: bag)
    }
}
