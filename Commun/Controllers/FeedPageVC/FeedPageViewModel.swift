//
//  FeedPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 3/19/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class FeedPageViewModel: PostsViewModel {
    let claimedPromos = BehaviorRelay<[String]?>(value: nil)
    
    override init(filter: PostsListFetcher.Filter = PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time), prefetch: Bool = true) {
        super.init(filter: filter, prefetch: prefetch)
        defer {
            getUserSettings()
        }
    }
    
    func getUserSettings() {
        RestAPIManager.instance.getUserSettings()
            .map {$0.system?.airdrop?.claimed ?? []}
            .subscribe(onSuccess: { (claimedPromos) in
                self.claimedPromos.accept(claimedPromos)
            })
            .disposed(by: disposeBag)
    }
}
