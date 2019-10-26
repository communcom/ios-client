//
//  CommunityController.swift
//  Commun
//
//  Created by Chung Tran on 10/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

let CommunityControllerPostDidChangeNotification = "CommunityControllerPostDidChangeNotification"

protocol CommunityController: class {
    // Required views
    var joinButton: CommunButton {get set}
    
    // Required properties
    var disposeBag: DisposeBag {get}
    var community: ResponseAPIContentGetCommunity? {get set}
    func setUp(with community: ResponseAPIContentGetCommunity)
}

extension CommunityController {
    // Apply changes to view when community changed
    func observerCommunityChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommunityControllerPostDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? ResponseAPIContentGetCommunity,
                    newCommunity == self.community
                    else {return}
                self.setUp(with: newCommunity)
            })
            .disposed(by: disposeBag)
    }
    
    // join
    func join() {
        guard community != nil else {return}
        
        // for reverse
        let originIsSubscribed = community!.isSubscribed ?? false
        
        // set value
        setIsSubscribed(!originIsSubscribed)
        
        // animate
        animateJoin()
        
        // notify changes
        community!.notifyChanged()
        
        // send request
        #warning("Mocking request")
        Completable.empty()
            .delay(0.8, scheduler: MainScheduler.instance)
            .do(onSubscribe: { [weak self] in
                self?.joinButton.isEnabled = false
            })
            .subscribe(onCompleted: { [weak self] in
                // re-enable button state
                self?.joinButton.isEnabled = true
                
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsSubscribed(originIsSubscribed)
                strongSelf.community?.notifyChanged()
                
                // re-enable button state
                strongSelf.joinButton.isEnabled = true
                
                // show error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func animateJoin() {
        
    }
    
    func setIsSubscribed(_ value: Bool) {
        guard community != nil,
            value != community?.isSubscribed
        else {return}
        community!.isSubscribed = value
        var subscribersCount: UInt16 = (community!.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0}
        else {
            if value == true {
                subscribersCount += 1
            }
            else {
                subscribersCount -= 1
            }
        }
        community!.subscribersCount = subscribersCount
    }
}
