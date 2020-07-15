//
//  MyProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyProfilePageViewModel: UserProfilePageViewModel {
    lazy var subscriptionsVM = SubscriptionsViewModel.ofCurrentUserTypeCommunity
    lazy var balancesVM = BalancesViewModel.ofCurrentUser
    
    override init(userId: String? = nil, username: String? = nil, authorizationRequired: Bool = true) {
        super.init(userId: userId, username: username)
        
        defer {
            balancesVM.update()
        }
    }
    
    override func reload() {
        subscriptionsVM.reload()
        balancesVM.update()
        super.reload()
    }
    
    override func bindHighlightCommunities() {
        // do nothing
    }
}
