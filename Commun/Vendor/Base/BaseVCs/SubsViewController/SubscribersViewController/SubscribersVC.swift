//
//  SubscribersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersVC: SubsViewController<ResponseAPIContentGetProfile, SubscribersCell>, ProfileCellDelegate {
    var dismissModalWhenPushing = false
    
    init(title: String? = nil, userId: String? = nil, communityId: String? = nil, prefetch: Bool = true) {
        let viewModel = SubscribersViewModel(userId: userId, communityId: communityId, prefetch: prefetch)
        super.init(viewModel: viewModel)
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
    
    override func modelSelected(_ user: ResponseAPIContentGetProfile) {
        let completion: (UIViewController) -> Void = {vc in
            vc.showProfileWithUserId(user.userId)
        }
        
        if dismissModalWhenPushing,
            self.isModal,
            let tabBar = presentingViewController as? TabBarVC,
            let vc = tabBar.selectedViewController as? BaseNavigationController
        {
            dismiss(animated: true) {
                completion(vc)
            }
        } else {
            completion(self)
        }
    }
}
