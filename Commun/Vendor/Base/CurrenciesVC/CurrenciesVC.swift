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

class CurrenciesVC: ListViewController<ResponseAPIGetCurrency, CurrencyCell>, UISearchResultsUpdating {
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
    override func setUp() {
        super.setUp()
        setLeftNavBarButtonForGoingBack()
        setUpSearchController()
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! CurrenciesViewModel
        
        Observable.merge(viewModel.items.asObservable(), viewModel.searchResult.filter {$0 != nil}.map {$0!}.asObservable())
            .map {[ListSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.searchResult
            .filter {$0 == nil}
            .subscribe(onNext: { (_) in
                viewModel.items.accept(viewModel.items.value)
            })
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
    fileprivate func setUpSearchController() {
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true

        layoutSearchBar()

        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.obscuresBackgroundDuringPresentation = false
    }

    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
    }

    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter our data with the string
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty
        {
            (viewModel as! CurrenciesViewModel).searchResult.accept(filteredItemsWithKeyword(searchText))
        } else {
            (viewModel as! CurrenciesViewModel).searchResult.accept(nil)
        }
    }
    
    func filteredItemsWithKeyword(_ keyword: String) -> [ResponseAPIGetCurrency] {
        viewModel.items.value.filter {$0.name.lowercased().contains(keyword.lowercased()) || ($0.fullName?.lowercased().contains(keyword.lowercased()) ?? false)}
    }
}
