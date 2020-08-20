//
//  CommunityCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol CommunityCellDelegate: class {
    func buttonFollowDidTouch(community: ResponseAPIContentGetCommunity)
    func forceFollow(_ value: Bool, community: ResponseAPIContentGetCommunity)
}

extension CommunityCellDelegate where Self: BaseViewController {
    func buttonFollowDidTouch(community: ResponseAPIContentGetCommunity) {
        // Prevent upvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            nonAuthVC.showAuthVC()
            return
        }
        
        // detect if community is in blacklist
        if community.isInBlacklist == true {
            self.showAlert(title: "unhide and follow".localized().uppercaseFirst, message: "this community is on your blacklist".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion:
            { (index) in
                if index == 0 {
                    self.sendFollowRequest(community: community)
                }
            })
            return
        }
        
        // if community is not in blacklist
        sendFollowRequest(community: community)
    }
    
    func forceFollow(_ value: Bool, community: ResponseAPIContentGetCommunity) {
        var community = community
        
        community.isSubscribed = !value
        
        buttonFollowDidTouch(community: community)
    }
    
    private func sendFollowRequest(community: ResponseAPIContentGetCommunity) {
        BlockchainManager.instance.triggerFollow(community: community)
            .subscribe { [weak self] (error) in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
