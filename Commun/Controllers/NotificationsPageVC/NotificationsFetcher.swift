//
//  ItemsFetcher.swift
//  Commun
//
//  Created by Chung Tran on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class NotificationsFetcher { 
    
    // MARK: - Parammeters
    var isFetching = false
    let limit = Config.paginationLimit
    var reachedTheEnd = false
    var fromId: String?
    
    // MARK: - Methods
    func reset() {
        reachedTheEnd = false
        isFetching = false
        fromId = nil
    }
    
    func fetchNext() -> Single<[ResponseAPIOnlineNotificationData]> {
        // Prevent duplicate request
        if self.isFetching || self.reachedTheEnd {return Single.never()}
        
        // Mark operation as fetching
        self.isFetching = true
        
        // Send request
        return NetworkService.shared.getNotifications(fromId: fromId)
            .flatMap({[weak self] historyResponse -> Single<[ResponseAPIOnlineNotificationData]> in
                guard let strongSelf = self else {return Single.never()}
                
                // Mark isFetching as false
                strongSelf.isFetching = false
                
                // Mark the end of the fetching
                if historyResponse.data.count < strongSelf.limit {
                    strongSelf.reachedTheEnd = true
                } else {
                    // Assign fromId
                    print(historyResponse.data.count)
                    strongSelf.fromId = historyResponse.data.last?._id
                }
                
                // Return data
                return Single<[ResponseAPIOnlineNotificationData]>.just(historyResponse.data)
            })
            .catchError({ (error) -> Single<[ResponseAPIOnlineNotificationData]> in
                self.isFetching = false
                return Single.never()
            })
    }
}
