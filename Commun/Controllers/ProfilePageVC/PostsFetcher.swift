//
//  PostsFetcher.swift
//  Commun
//
//  Created by Chung Tran on 18/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class PostsFetcher {
    
    // MARK: - Parammeters
    var isFetching = false
    let limit = Config.paginationLimit
    var reachedTheEnd = false
    var sequenceKey: String?
    
    // MARK: - Methods
    func reset() {
        reachedTheEnd = false
        isFetching = false
        sequenceKey = nil
    }
    
    func fetchNext() -> Single<[ResponseAPIContentGetPost]> {
        // Prevent duplicate request
        if self.isFetching || self.reachedTheEnd {return Single.never()}
        
        // Mark operation as fetching
        self.isFetching = true
        
        // Send request
        return NetworkService.shared.loadFeed(nil, withFeedType: .time, withFeedTypeMode: .byUser)
            .do(onNext: { result in
                // mark isFetching as false
                self.isFetching = false
                
                // mark the end of the fetch
                if let count = result.items?.count,
                    count < self.limit {
                    self.reachedTheEnd = true
                }
                
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
                
            }, onError: { (error) in
                // mark isFetching as false
                self.isFetching = false
            })
            .map {$0.items ?? []}
            .asSingle()
    }
}
