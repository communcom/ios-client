//
//  ReferralUsersVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReferralUsersVC: SubsViewController<ResponseAPIContentGetProfile, SubscribersCell> {
    init() {
        let vm = ReferralUsersViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleListEmpty() {
        let title = "no referral users"
        let description = "no referral users found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ user: ResponseAPIContentGetProfile) {
        // do nothing
    }
}
