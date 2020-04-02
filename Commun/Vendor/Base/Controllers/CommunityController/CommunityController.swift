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
            vc.showAlert(title: "unhide and follow".localized().uppercaseFirst, message: "this community is on your blacklist".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
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
        guard let community = community else {return}
        NetworkService.shared.triggerFollow(community: community)
            .subscribe(onError: { (error) in
                UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: self.disposeBag)
    }
}
