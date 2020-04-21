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

class CurrenciesVC: ListViewController<ResponseAPIGetCurrency, CurrencyCell>, SearchableViewControllerType {
    var searchBar: UISearchBar {
        get {
            searchController.searchBar
        }
        set {}
    }
    
    // MARK: - Properties
    lazy var searchController = UISearchController.default()
    
    // MARK: - Initializers
    init() {
        let vm = CurrenciesViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorners()
    }
    
    override func setUp() {
        super.setUp()
        setLeftNavBarButtonForGoingBack()
    }
    
    override func viewWillSetUpTableView() {
        self.definesPresentationContext = true
        layoutSearchBar()
        super.viewWillSetUpTableView()
    }
    
    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
    }
    
    override func bind() {
        super.bind()
        
        bindSearchBar()
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! CurrenciesViewModel
        
        Observable.merge(viewModel.items.asObservable(), viewModel.searchResult.filter {$0 != nil}.map {$0!}.asObservable())
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .do(onNext: { (items) in
                if items.count == 0 && self.viewModel.state.value != .loading(true) {
                    self.handleListEmpty()
                }
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
    func searchBarIsSearchingWithQuery(_ query: String) {
        let viewModel = self.viewModel as! CurrenciesViewModel
        viewModel.searchResult.accept(
            viewModel.items.value.filter {$0.name.lowercased().contains(query.lowercased()) || ($0.fullName?.lowercased().contains(query.lowercased()) ?? false)}
        )
    }
    
    func searchBarDidCancelSearching() {
        viewModel.items.accept(viewModel.items.value)
    }
}
