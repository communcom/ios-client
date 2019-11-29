//
//  SubscribersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersVC: SubsViewController<ResponseAPIContentResolveProfile, SubscribersCell> {
    init(title: String? = nil, userId: String? = nil, communityId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SubscribersViewModel(userId: userId, communityId: communityId)
        defer {
            self.title = title
            viewModel.fetchNext()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleListEmpty() {
        let title = "no subscribers"
        let description = "no subscribers found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
