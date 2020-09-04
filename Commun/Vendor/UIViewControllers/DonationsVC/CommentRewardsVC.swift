//
//  CommentRewardsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommentRewardsVC: DonationsVC {
    override func setUp() {
        super.setUp()
        title = "donations".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
    }
}
