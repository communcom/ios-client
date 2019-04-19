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
                switch item {
                case .posts:
                    let customFetcher = PostsFetcher()
                    self.itemsFetcher = customFetcher
                    customFetcher.reset()
                    return customFetcher.fetchNext()
                        .map {$0 as [ResponseAPIContentGetPost]}
                    
                case .comments:
                    #warning("Fetcher for comments")
                    let customFetcher = ItemsFetcher<ResponseAPIContentGetComment>()
                    self.itemsFetcher = customFetcher
                    customFetcher.reset()
                    return customFetcher.fetchNext()
                        .map {$0 as [ResponseAPIContentGetComment]}
                }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: bag)
        
        // Retrive items after segemented changes
        segmentedItem
            .subscribe(onNext: {_ in
                self.resetItems()
                self.fetchNext()
            })
            .disposed(by: bag)
    }
    
    func reload() {
        // reload profile
        profile.accept(nil)
        
        // reset items
        resetItems()
        
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
    private func resetItems() {
        switch segmentedItem.value {
        case .posts:
            guard let fetcher = itemsFetcher as? PostsFetcher else {return}
            fetcher.reset()
        case .comments:
            #warning("Fetcher for comments")
            guard let fetcher = itemsFetcher as? ItemsFetcher<ResponseAPIContentGetComment> else {return}
            fetcher.reset()
        }
        items.accept([])
    }

    func fetchNext() {
        let single: Single<[Decodable]>
        switch segmentedItem.value {
        case .posts:
            guard let fetcher = itemsFetcher as? PostsFetcher else {return}
            single = fetcher.fetchNext().map {$0 as [ResponseAPIContentGetPost]}
        case .comments:
            #warning("Fetcher for comments")
            guard let fetcher = itemsFetcher as? ItemsFetcher<ResponseAPIContentGetComment> else {return}
            single = fetcher.fetchNext().map {$0 as [ResponseAPIContentGetComment]}
        }
        single
            .asDriver(onErrorJustReturn: [])
            .map {self.items.value + $0}
            .drive(items)
            .disposed(by: bag)
    }
}
