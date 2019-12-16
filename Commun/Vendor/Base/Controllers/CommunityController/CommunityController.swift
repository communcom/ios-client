//
//  CommunityController.swift
//  Commun
//
//  Created by Chung Tran on 10/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

extension ResponseAPIContentGetCommunity {
    mutating func setIsSubscribed(_ value: Bool) {
        guard value != isSubscribed
        else {return}
        isSubscribed = value
        var subscribersCount: UInt64 = (self.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0} else {
            if value == true {
                subscribersCount += 1
            } else {
                subscribersCount -= 1
            }
        }
        self.subscribersCount = subscribersCount
    }
}

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
    func observeCommunityChange() {
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.identity == self.community?.identity}
            .subscribe(onNext: {newCommunity in
                self.setUp(with: newCommunity)
            })
            .disposed(by: disposeBag)
    }
    
    // join
    func toggleJoin() {
        guard community != nil else {return}
        let id = community!.communityId
        
        // for reverse
        let originIsSubscribed = community!.isSubscribed ?? false
        
        // set value
        setIsSubscribed(!originIsSubscribed)
        community?.isBeingJoined = true
        
        // notify changes
        community!.notifyChanged()
        
        // send request
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        let request: Completable
        
        if originIsSubscribed {
            request = RestAPIManager.instance.unfollowCommunity(id)
                .flatMapToCompletable()
        } else {
            request = RestAPIManager.instance.followCommunity(id)
                .flatMapToCompletable()
        }
        
        request
            .subscribe(onCompleted: { [weak self] in
                // re-enable state
                self?.community?.isBeingJoined = false
                self?.community?.notifyChanged()
                
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsSubscribed(originIsSubscribed)
                strongSelf.community?.isBeingJoined = false
                strongSelf.community?.notifyChanged()
                
                // show error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func setIsSubscribed(_ value: Bool) {
        guard community != nil,
            value != community?.isSubscribed
        else {return}
        community!.isSubscribed = value
        var subscribersCount: UInt64 = (community!.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0} else {
            if value == true {
                subscribersCount += 1
            } else {
                subscribersCount -= 1
            }
        }
        community!.subscribersCount = subscribersCount
    }
}
