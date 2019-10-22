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

typealias FilterType = Equatable

class ItemsFetcher<T: Decodable> {
    
    // MARK: - Parammeters
    var isFetching = false
    let limit = UInt(Config.paginationLimit)
    var offset: UInt = 0
    var reachedTheEnd = false
    var request: Single<[T]>! {
        return nil
    }
    var lastError: Error?
    
    // MARK: - Methods
    func reset() {
        lastError       = nil
        reachedTheEnd   = false
        isFetching      = false
        offset = 0
    }
    
    func fetchNext() -> Maybe<[T]> {
        // Resign error
        lastError = nil
        
        // Prevent duplicate request
        if self.isFetching || self.reachedTheEnd {
            return .empty()
        }
        
        // Mark operation as fetching
        self.isFetching = true
        
        // Send request
        if request == nil {
            fatalError("Must override request")
        }
        return request
            .do(onSuccess: { result in
                // next
                self.offset += self.limit
                
                // mark isFetching as false
                self.isFetching = false
                
                // mark the end of the fetch
                if result.count < self.limit {
                    self.reachedTheEnd = true
                }
                
                self.lastError = nil
            }, onError: { (error) in
                // mark isFetching as false
                self.isFetching = false
                
                // resign error
                self.lastError = error
            })
            .asMaybe()
    }
}
