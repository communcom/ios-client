//
//  SubscriptionsCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

class SubscriptionsVC: SubsViewController<ResponseAPIContentGetSubscriptionsItem, SubscriptionsUserCell> {
    var hideFollowButton = false
    private var isNeedHideCloseButton = false

    init(title: String? = nil, userId: String?, type: GetSubscriptionsType) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SubscriptionsViewModel(userId: userId, type: type)
        defer {self.title = title}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.isNeedHideCloseButton = true
        viewModel = SubscriptionsViewModel(userId: nil, type: .user)
        defer {self.title = "followings".localized().uppercaseFirst}
    }
    
    override func setUp() {
        super.setUp()
        
        if isNeedHideCloseButton {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func registerCell() {
        tableView.register(SubscriptionsUserCell.self, forCellReuseIdentifier: "SubscriptionsUserCell")
        tableView.register(SubscriptionsCommunityCell.self, forCellReuseIdentifier: "SubscriptionsCommunityCell")
    }
    
    override func configureCell(with subscription: ResponseAPIContentGetSubscriptionsItem, indexPath: IndexPath) -> UITableViewCell {
        if let community = subscription.communityValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscriptionsCommunityCell") as! SubscriptionsCommunityCell
            cell.setUp(with: community)
            
            cell.roundedCorner = []
            
            if indexPath.row == 0 {
                cell.roundedCorner.insert([.topLeft, .topRight])
            }
            
            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }

            cell.joinButton.isHidden = self.hideFollowButton

            return cell
        }
        
        if let profile = subscription.userValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscriptionsUserCell") as! SubscriptionsUserCell
            cell.setUp(with: profile)
            
            cell.roundedCorner = []
            
            if indexPath.row == 0 {
                cell.roundedCorner.insert([.topLeft, .topRight])
            }
            
            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            
            return cell
        }
        
        if indexPath.row >= self.viewModel.items.value.count - 5 {
            self.viewModel.fetchNext()
        }
        
        return UITableViewCell()
    }
    
    override func handleListEmpty() {
        var title = "no subscriptions"
        var description = "no subscriptions found"
        switch (viewModel as! SubscriptionsViewModel).type {
        case .community:
            title = "no subscriptions"
            description = "user have not subscribed to any community"
        case .user:
            title = "no subscribers"
            description = "no subscribers found"
        }
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
