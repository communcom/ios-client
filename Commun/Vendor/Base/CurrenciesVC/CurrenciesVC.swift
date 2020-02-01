//
//  CurrenciesVC.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CurrenciesVC: ListViewController<ResponseAPIGetCurrency, CurrencyCell> {
    // MARK: - Properties
    override var isSearchEnabled: Bool {true}
    
    // MARK: - Initializers
    init() {
        let vm = CurrenciesViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        setLeftNavBarButtonForGoingBack()
    }
    
    override func handleListEmpty() {
        let title = "no currencies"
        let description = "there is no currency available"
        tableView.addEmptyPlaceholderFooterView(emoji: "👁", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    // MARK: - Search manager
    override func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            viewModel.items.accept(viewModel.items.value)
            return
        }
        viewModel.searchResult.accept(
            viewModel.items.value.filter {$0.name.lowercased().contains(keyword.lowercased()) || ($0.fullName?.lowercased().contains(keyword.lowercased()) ?? false)}
        )
    }
}
