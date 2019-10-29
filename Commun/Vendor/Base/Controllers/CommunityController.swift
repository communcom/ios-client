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

let CommunityControllerCommunityDidChangeNotification = "CommunityControllerCommunityDidChangeNotification"

protocol CommunityType: Equatable {
    var communityId: String {get}
    var name: String {get}
    var isSubscribed: Bool? {get set}
    var subscribersCount: UInt64? {get set}
}

extension CommunityType {
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CommunityControllerCommunityDidChangeNotification), object: self)
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
    func observerCommunityChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommunityControllerCommunityDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? Community,
                    newCommunity == self.community
                    else {return}
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
        
        // animate
        animateJoin()
        
        // notify changes
        community!.notifyChanged()
        
        // send request
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        let request: Completable
        
        if originIsSubscribed {
            request = RestAPIManager.instance.rx.unfollowCommunity(id)
                .flatMapToCompletable()
        }
        else {
            request = RestAPIManager.instance.rx.followCommunity(id)
                .flatMapToCompletable()
        }
        
        request
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
