//
//  SearchableBalancesVC.swift
//  Commun
//
//  Created by Chung Tran on 6/10/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SearchableBalancesVC: BalancesVC, SearchableViewControllerType {
    var tableViewTopConstraint: NSLayoutConstraint?
    
    lazy var searchContainerView = UIView(backgroundColor: .appWhiteColor)
    var searchBar = UISearchBar.default()
    
    override init(userId: String? = nil, canChooseCommun: Bool = true, showEmptyBalances: Bool = true, completion: ((ResponseAPIWalletGetBalance) -> Void)? = nil) {
        super.init(userId: userId, canChooseCommun: canChooseCommun, showEmptyBalances: showEmptyBalances, completion: completion)
        searchBar.showsCancelButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reset search result
        viewModel.items.accept(viewModel.items.value)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.roundCorner()
    }
    
    override func viewWillSetUpTableView() {
        layoutSearchBar()
        super.viewWillSetUpTableView()
    }
    
    override func setUp() {
        super.setUp()
        showShadowWhenScrollUp = false
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! BalancesViewModel
        
        Observable.merge(viewModel.items.asObservable(), viewModel.searchResult.filter {$0 != nil}.map {$0!}.asObservable())
            .map {self.mapItems(items: $0)}
            .do(onNext: { (items) in
                if items.count == 0 {
                    self.handleListEmpty()
                }
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Search manager
    func layoutSearchBar() {
        fatalError("Must override")
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        let viewModel = self.viewModel as! BalancesViewModel
        viewModel.searchResult.accept(
            viewModel.items.value.filter {($0.name?.lowercased().contains(query.lowercased()) ?? false) || $0.symbol.lowercased().contains(query.lowercased())}
        )
    }
    
    func searchBarDidCancelSearching() {
        searchBar.text = nil
        viewModel.items.accept(viewModel.items.value)
    }
}
