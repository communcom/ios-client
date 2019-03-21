//
//  FeedPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class FeedPageViewModel {
    
    private let disposeBag = DisposeBag()
    
    var items = Variable<[ResponseAPIContentGetPost]>([])
    var errors = PublishSubject<Error>()
    
    var paginationKey: String? = ""
    var isLoading: Bool = false
    
    var sortType: FeedTimeFrameMode = .all
    var feedType: FeedSortMode = .popular
    
    init() {
       loadFeed()
    }
    
    func loadFeed() {
        if !isLoading && paginationKey != nil {
            isLoading = true
            
             NetworkService.shared.loadFeed(paginationKey, withSortType: sortType, withFeedType: feedType).subscribe(onNext: { [weak self] feed in
                var newItems = self?.items.value ?? []
                newItems.append(contentsOf: feed.items ?? [])
                self?.items.value = newItems
                self?.paginationKey = feed.sequenceKey
                self?.isLoading = false
            }, onError: { [weak self] error in
                self?.paginationKey = nil
                self?.isLoading = false
            }).disposed(by: disposeBag)
        }
    }
    
    func updateFeedWithFrameMode(_ mode: FeedTimeFrameMode) {
        sortType = mode
        self.paginationKey = ""
        items.value = []
        loadFeed()
    }
    
}
