//
//  OtherWalletVC.swift
//  Commun
//
//  Created by Chung Tran on 1/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class OtherBalancesWalletVC: CommunWalletVC {
    // MARK: - Properties
    var initialSymbol: String
    var initialSymbolDidSelect = false
    
    override var balances: [ResponseAPIWalletGetBalance] {
        super.balances.filter {$0.symbol != Config.defaultSymbol}
    }
    
    var currentBalance: ResponseAPIWalletGetBalance? {
        balances[safe: (headerView as! WalletHeaderView).selectedIndex]
    }
    
    // MARK: - Subviews
    override func setUp() {
        isCommunBalance = false
        super.setUp()
        tableHeaderView.setMyPointHidden(true)
    }
    
    // MARK: - Initializers
    init(
        balances: [ResponseAPIWalletGetBalance]? = nil,
        symbol: String,
        subscriptions: [ResponseAPIContentGetSubscriptionsItem]? = nil,
        history: [ResponseAPIWalletGetTransferHistoryItem]? = nil
    ) {
        initialSymbol = symbol
        let vm = WalletViewModel(symbol: symbol)
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        if !initialSymbolDidSelect && !balances.isEmpty {
            if let index = self.balances.firstIndex(where: {$0.symbol == initialSymbol}) {
                (headerView as! WalletHeaderView).selectedIndex = index
            }
            initialSymbolDidSelect = true
        }
        (headerView as! WalletHeaderView).carousel?.reloadData()
        super.reloadData()
    }
    
    override func createHeaderView() -> CommunWalletHeaderView {
        let headerView = WalletHeaderView(forAutoLayout: ())
        headerView.dataSource = self
        return headerView
    }
    
    // MARK: - Method
    override func createConvertVC() -> WalletConvertVC? {
        guard let balance = currentBalance else { return nil }
        return WalletBuyCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, symbol: balance.symbol)
    }
}

extension OtherBalancesWalletVC: WalletHeaderViewDelegate {
    func walletHeaderView(_ headerView: WalletHeaderView, currentIndexDidChangeTo index: Int) {
        let currentFilter = (viewModel as! TransferHistoryViewModel).filter.value
        guard let balance = balances[safe: index] else {return}
        filterChanged(TransferHistoryListFetcher.Filter(userId: currentFilter.userId, direction: currentFilter.direction, transferType: currentFilter.transferType, symbol: balance.symbol, rewards: currentFilter.rewards))
    }
}
