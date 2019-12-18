//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletVC: ListViewController<ResponseAPIWalletGetTransferHistoryItem, TransferHistoryItemCell> {
    // MARK: - Properties
    override var tableViewMargin: UIEdgeInsets {
        UIEdgeInsets(inset: 10)
    }
    
    init() {
        let fetcher = TransferHistoryListFetcher()
        let viewModel = TransferHistoryViewModel(fetcher: fetcher)
        super.init(viewModel: viewModel)
        
        defer {
            self.viewModel.fetchNext()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func configureCell(with item: ResponseAPIWalletGetTransferHistoryItem, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! TransferHistoryItemCell
        
        cell.roundedCorner = []
        
        if indexPath.row == 0 {
            cell.roundedCorner.insert([.topLeft, .topRight])
        }
        
        if indexPath.row == self.viewModel.items.value.count - 1 {
            cell.roundedCorner.insert([.bottomLeft, .bottomRight])
        }
        
        return cell
    }
    
    override func handleListEmpty() {
        let title = "no transactions"
        let description = "you haven't had any transactions yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "👁", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}
