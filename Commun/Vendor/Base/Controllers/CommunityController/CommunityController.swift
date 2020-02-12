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
        var subscribersCount: Int64 = (self.subscribersCount ?? 0)
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
                guard let community = self.community?.newUpdatedItem(from: newCommunity) else {return}
                self.setUp(with: community)
            })
            .disposed(by: disposeBag)
    }
    
    // join
    func toggleJoin() {
        guard let vc = UIApplication.topViewController() else {return}
        if community?.isInBlacklist == true
        {
            vc.showAlert(title: "unhide and follow".localized().uppercaseFirst, message: "this community is on your blacklist. Do you really want to unhide and follow it anyway?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
            { (index) in
                if index == 0 {
                    self.sendJoinRequest()
                }
            })
        } else {
            sendJoinRequest()
        }
    }
    
    private func sendJoinRequest() {
        guard community != nil else {return}
        let id = community!.communityId
        
        // for reverse
        let originIsSubscribed = community!.isSubscribed ?? false
        let originIsInBlacklist = community!.isInBlacklist ?? false
        
        // set value
        setIsSubscribed(!originIsSubscribed)
        community?.isBeingJoined = true
        community?.isInBlacklist = false
        
        // notify changes
        community!.notifyChanged()
        
        // send request
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        let request: Single<String>
        
        if originIsSubscribed {
            request = BlockchainManager.instance.unfollowCommunity(id)
        } else {
            if originIsInBlacklist {
                request = BlockchainManager.instance.unhideCommunity(id)
                    .flatMap {_ in BlockchainManager.instance.followCommunity(id)}
            } else {
                request = BlockchainManager.instance.followCommunity(id)
            }
        }
        
        request
            .flatMapToCompletable()
            .subscribe(onCompleted: { [weak self] in
                // re-enable state
                self?.community?.isBeingJoined = false
                self?.community?.notifyChanged()
                
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsSubscribed(originIsSubscribed)
                strongSelf.community?.isBeingJoined = false
                strongSelf.community?.isInBlacklist = originIsInBlacklist
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
        var subscribersCount: Int64 = (community!.subscribersCount ?? 0)
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
