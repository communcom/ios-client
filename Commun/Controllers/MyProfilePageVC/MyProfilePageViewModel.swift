//
//  MyProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyProfilePageViewModel: UserProfilePageViewModel {
    lazy var subscriptionsVM = SubscriptionsViewModel(userId: profileId, type: .community)
    lazy var balancesVM = BalancesViewModel()
    
    override func reload() {
        subscriptionsVM.reload()
        balancesVM.reload()
        super.reload()
    }
    
    override func bindHighlightCommunities() {
        // do nothing
    }
}
