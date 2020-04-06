//
//  SubscriptionsCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

class SubscriptionsVC: SubsViewController<ResponseAPIContentGetSubscriptionsItem, SubscriptionsUserCell>, CommunityCellDelegate, ProfileCellDelegate {
    // MARK: - Properties
    var hideFollowButton = false
    private var isNeedHideCloseButton = false
    var dismissModalWhenPushing = false
    
    // MARK: - Class Initialization
    init(title: String? = nil, userId: String? = nil, type: GetSubscriptionsType, prefetch: Bool = true) {
        let viewModel = SubscriptionsViewModel(userId: userId, type: type, prefetch: prefetch)
        super.init(viewModel: viewModel)
        defer {self.title = title}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
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
            cell.delegate = self
            
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
            cell.delegate = self
            
            cell.roundedCorner = []
            
            if indexPath.row == 0 {
                cell.roundedCorner.insert([.topLeft, .topRight])
            }
            
            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func handleListEmpty() {
        var titleValue = "empty subscriptions title"
        var descriptionValue = "empty subscriptions description"
        var buttonTitleValue: String?
        
        switch (viewModel as! SubscriptionsViewModel).type {
        case .community:
            titleValue          =   "empty subscriptions title".localized().uppercaseFirst
            descriptionValue    =   "empty subscriptions description".localized().uppercaseFirst
            buttonTitleValue    =   "empty subscriptions button title".localized().uppercaseFirst
            
        case .user:
            titleValue          =   "empty subscriptions title".localized().uppercaseFirst
            descriptionValue    =   "empty subscriptions user description".localized().uppercaseFirst
        }
        
        tableView.addEmptyPlaceholderFooterView(title: titleValue,
                                                description: descriptionValue,
                                                buttonLabel: buttonTitleValue,
                                                buttonAction: {
                                                    Logger.log(message: "Action button tapped...", event: .debug)
        })
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetSubscriptionsItem) {
        let completion: (UIViewController) -> Void = {vc in
            if let community = item.communityValue {
                vc.showCommunityWithCommunityId(community.communityId)
            }
            if let user = item.userValue {
                vc.showProfileWithUserId(user.userId)
            }
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
