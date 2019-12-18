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
    
    override func bindHighlightCommunities() {
        // do nothing
    }
}
