//
//  CommunWalletAddFriendVC.swift
//  Commun
//
//  Created by Chung Tran on 2/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletAddFriendVC: SubscriptionsVC {
    override var isSearchEnabled: Bool {true}
    
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    
    // MARK: - Initializers
    init() {
        super.init(title: "add friends".localized().uppercaseFirst, type: .user, prefetch: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetSubscriptionsItem) {
        guard let user = item.userValue else {return}
        if user.isSubscribed == true {
            searchController.searchBar.resignFirstResponder()
            searchController.dismiss(animated: true) {
                self.completion?(user)
            }
        }
    }
}
