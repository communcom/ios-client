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
    var currentBalance: ResponseAPIWalletGetBalance? {
        balances?[safe: (headerView as! WalletHeaderView).selectedIndex]
    }
    
    // MARK: - Subviews
    override func setUp() {
        super.setUp()
        tableHeaderView.setMyPointHidden(true)
    }
    
    // MARK: - Initializers
    init(
        balances: [ResponseAPIWalletGetBalance]? = nil,
        subscriptions: [ResponseAPIContentGetSubscriptionsItem]? = nil,
        history: [ResponseAPIWalletGetTransferHistoryItem]? = nil
    ) {
        let vm = WalletViewModel(balances: balances, subscriptions: subscriptions, history: history)
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        (headerView as! WalletHeaderView).carousel.reloadData()
        super.reloadData()
    }
    
    override func createHeaderView() -> CommunWalletHeaderView {
        let headerView = WalletHeaderView(forAutoLayout: ())
        headerView.delegate = self
        headerView.dataSource = self
        return headerView
    }
    
    // MARK: - Methods
    override func createConvertVC() -> WalletConvertVC? {
        guard let balance = currentBalance else {return nil}
        return WalletBuyCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, symbol: balance.symbol)
    }
    
    override func data(forWalletHeaderView headerView: CommunWalletHeaderView) -> [ResponseAPIWalletGetBalance]? {
        super.data(forWalletHeaderView: headerView)?.filter {$0.symbol != "CMN"}
    }
}

extension OtherBalancesWalletVC: WalletHeaderViewDelegate {
    func walletHeaderView(_ headerView: WalletHeaderView, currentIndexDidChangeTo index: Int) {
//        tableHeaderView.setMyPointHidden(index != 0)
    }
}
