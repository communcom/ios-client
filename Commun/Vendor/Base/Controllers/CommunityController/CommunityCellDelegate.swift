//
//  CommunityCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

protocol CommunityCellDelegate: class {
    func buttonFollowDidTouch(community: ResponseAPIContentGetCommunity)
    func forceFollow(_ value: Bool, community: ResponseAPIContentGetCommunity)
}

extension CommunityCellDelegate where Self: BaseViewController {
    func buttonFollowDidTouch(community: ResponseAPIContentGetCommunity) {
        NetworkService.shared.triggerFollow(community: community)
            .subscribe { [weak self] (error) in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func forceFollow(_ value: Bool, community: ResponseAPIContentGetCommunity) {
        var community = community
        
        community.isSubscribed = !value
        
        buttonFollowDidTouch(community: community)
    }
}
