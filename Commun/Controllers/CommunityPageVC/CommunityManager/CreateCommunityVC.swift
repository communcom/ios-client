//
//  CreateCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 9/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreateCommunityVC: CreateCommunityFlowVC {
    override func setUp() {
        super.setUp()
        continueButton.setTitle("create community".localized().uppercaseFirst, for: .normal)
    }
    
    override func continueButtonDidTouch() {
        // TODO: - Create community
    }
}
