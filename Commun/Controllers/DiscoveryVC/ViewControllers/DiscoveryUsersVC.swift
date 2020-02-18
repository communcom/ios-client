//
//  DiscoveryUsersVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoveryUsersVC: SubscribersVC {
    init(prefetch: Bool = true) {
        super.init(userId: Config.currentUser?.id, prefetch: prefetch)
        
        defer {
            showShadowWhenScrollUp = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
