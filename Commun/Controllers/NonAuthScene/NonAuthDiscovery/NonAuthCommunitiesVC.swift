//
//  NonAuthCommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 7/21/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthCommunitiesVC: CommunitiesVC, NonAuthVCType {
    init() {
        let viewModel = CommunitiesViewModel(type: .all, authorizationRequired: false)
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
