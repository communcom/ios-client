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
    
    let fetcher = NotificationsFetcher()
    
    // Handlers
    var loadingHandler: (() -> Void)?
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    
    func reload() {
        fetcher.reset()
        list.accept([])
        fetchNext()
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .do(onSubscribed: {
                self.loadingHandler?()
            })
            .subscribe(onSuccess: { (list) in
                if list.count > 0 {
                    let newList = list.filter {!self.list.value.contains($0)}
                    self.list.accept(self.list.value + newList)
                }
                
                if self.fetcher.reachedTheEnd {
                    self.listEndedHandler?()
                    return
                }
            }, onError: { (error) in
                self.fetchNextErrorHandler?(error)
            })
            .disposed(by: bag)
    }
    
    func markAsRead(_ item: ResponseAPIOnlineNotificationData) -> CocoaAction {
        return CocoaAction {
            // TODO: markAsRead
            return Observable.empty()
        }
    }
}
