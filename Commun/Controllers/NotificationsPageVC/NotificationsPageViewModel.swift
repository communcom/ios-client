//
//  NotificationsPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright (c) 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

struct NotificationsPageViewModel: ListViewModelType {
    let bag = DisposeBag()
    let list = BehaviorRelay<[ResponseAPIOnlineNotificationData]>(value: [])
    let lastError = BehaviorRelay<Error?>(value: nil)
    
    let fetcher = NotificationsFetcher()
    
    // Handlers
    var loadingHandler: (() -> Void)?
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    
    func reload() {
        fetcher.reset()
        list.accept([])
        lastError.accept(nil)
        fetchNext()
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .do(onSubscribe: {
                self.loadingHandler?()
            })
            .subscribe(onSuccess: { (list) in
                // Reset error
                self.lastError.accept(nil)
                
                if list.count > 0 {
                    let newList = list.filter {!self.list.value.contains($0) && $0.eventType != "unsubscribe"}
                    self.list.accept(self.list.value + newList)
                }
                
                if self.fetcher.reachedTheEnd {
                    self.listEndedHandler?()
                    return
                }
            }, onError: { (error) in
                self.lastError.accept(error)
                self.fetchNextErrorHandler?(error)
            })
            .disposed(by: bag)
    }
    
    func markAsRead(_ item: ResponseAPIOnlineNotificationData) -> Completable {
        return NetworkService.shared.markAsRead(ids: [item._id])
    }
}
