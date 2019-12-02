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

protocol CommunityType: ListItemType {
    var communityId: String {get}
    var name: String {get}
    var isSubscribed: Bool? {get set}
    var subscribersCount: UInt64? {get set}
    var identity: String {get}
    var avatarUrl: String? {get}
    var coverUrl: String? {get}
    var isBeingJoined: Bool? {get set}
}

extension CommunityType {
    mutating func setIsSubscribed(_ value: Bool) {
        guard value != isSubscribed
        else {return}
        isSubscribed = value
        var subscribersCount: UInt64 = (self.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0}
        else {
            if value == true {
                subscribersCount += 1
            }
            else {
                subscribersCount -= 1
            }
        }
        self.subscribersCount = subscribersCount
    }
}

extension ResponseAPIContentGetCommunity: CommunityType {}
extension ResponseAPIContentGetSubscriptionsCommunity: CommunityType {
    var subscribersCount: UInt64? {
        get {
            return nil
        }
        set {
            
        }
    }
}

protocol CommunityController: class {
    associatedtype Community: CommunityType
    // Required views
    var joinButton: CommunButton {get set}
    
    // Required properties
    var disposeBag: DisposeBag {get}
    var community: Community? {get set}
    func setUp(with community: Community)
}

extension CommunityController {
    // Apply changes to view when community changed
    func observeCommunityChange() {
        Community.observeItemChanged()
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
        
        // animate
        animateJoin()
        
        // notify changes
        community!.notifyChanged()
        
        // send request
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        let request: Completable
        
        if originIsSubscribed {
            request = RestAPIManager.instance.unfollowCommunity(id)
                .flatMapToCompletable()
        }
        else {
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
    
    func animateJoin() {
        CATransaction.begin()
        
        let moveDownAnim = CABasicAnimation(keyPath: "transform.scale")
        moveDownAnim.byValue = 1.2
        moveDownAnim.autoreverses = true
        joinButton.layer.add(moveDownAnim, forKey: "transform.scale")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        joinButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
    
    func setIsSubscribed(_ value: Bool) {
        guard community != nil,
            value != community?.isSubscribed
        else {return}
        community!.isSubscribed = value
        var subscribersCount: UInt64 = (community!.subscribersCount ?? 0)
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
