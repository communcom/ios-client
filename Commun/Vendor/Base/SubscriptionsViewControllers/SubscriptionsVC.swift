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

class SubscriptionsVC: ListViewController<ResponseAPIContentGetSubscriptionsItem> {
    override var tableViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    init(userId: String?, type: GetSubscriptionsType) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SubscriptionsViewModel(userId: userId, type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        tableView.register(SubscriptionsUserCell.self, forCellReuseIdentifier: "SubscriptionsUserCell")
        tableView.register(SubscriptionsCommunityCell.self, forCellReuseIdentifier: "SubscriptionsCommunityCell")
        tableView.cornerRadius = 10
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        tableView.separatorColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, subscription in
                if let community = subscription.communityValue {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscriptionsCommunityCell") as! SubscriptionsCommunityCell
                    cell.setUp(with: community)
                    return cell
                }
                
                if let profile = subscription.userValue {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscriptionsUserCell") as! SubscriptionsUserCell
                    cell.setUp(with: profile)
                    return cell
                }
                
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                return UITableViewCell()
            }
        )
    }
    
    override func bind() {
        super.bind()
        tableView.rx.modelSelected(ResponseAPIContentGetSubscriptionsItem.self)
            .subscribe(onNext: { (item) in
                if let community = item.communityValue {
                    self.showCommunityWithCommunityId(community.communityId)
                }
                if let user = item.userValue {
                    self.showProfileWithUserId(user.userId)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
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
