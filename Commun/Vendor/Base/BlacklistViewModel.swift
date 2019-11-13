//
//  BlacklistViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class BlacklistViewModel: ListViewModel<ResponseAPIContentGetBlacklistItem> {
    let type: GetBlacklistType
    init(type: GetBlacklistType) {
        let fetcher = BlacklistFetcher(type: type)
        self.type = type
        super.init(fetcher: fetcher)
    }
    
    override func observeItemChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetBlacklistUser.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newUser = notification.object as? ResponseAPIContentGetBlacklistUser
                    else {return}
                self.updateItem(.user(newUser))
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetBlacklistCommunity.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? ResponseAPIContentGetBlacklistCommunity
                    else {return}
                self.updateItem(.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetBlacklistUser.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let updatedUser = notification.object as? ResponseAPIContentGetBlacklistUser
                    else {return}
                self.deleteItem(.user(updatedUser))
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetBlacklistCommunity.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let updateCommunity = notification.object as? ResponseAPIContentGetBlacklistCommunity
                    else {return}
                self.deleteItem(.community(updateCommunity))
            })
            .disposed(by: disposeBag)
    }
}
