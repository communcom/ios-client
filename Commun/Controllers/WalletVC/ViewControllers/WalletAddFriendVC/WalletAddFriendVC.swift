//
//  CommunWalletAddFriendVC.swift
//  Commun
//
//  Created by Chung Tran on 2/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletAddFriendVC: SubscriptionsVC, WalletAddFriendCellDelegate {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseNavigationController?.changeStatusBarStyle(.default)
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func registerCell() {
        tableView.register(WalletAddFriendCell.self, forCellReuseIdentifier: "WalletAddFriendCell")
    }
    
    override func configureCell(with subscription: ResponseAPIContentGetSubscriptionsItem, indexPath: IndexPath) -> UITableViewCell {
        if let profile = subscription.userValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "WalletAddFriendCell") as! WalletAddFriendCell
            cell.setUp(with: profile)
            cell.delegate = self as WalletAddFriendCellDelegate
            
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
    
    func sendPointButtonDidTouch(friend: ResponseAPIContentGetProfile) {
        if searchController.searchBar.isFirstResponder {
            searchController.searchBar.resignFirstResponder()
            searchController.dismiss(animated: true) {
                self.completion?(friend)
            }
        } else {
            self.completion?(friend)
        }
    }
}
