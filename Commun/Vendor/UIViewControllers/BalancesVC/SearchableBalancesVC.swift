//
//  SearchableBalancesVC.swift
//  Commun
//
//  Created by Chung Tran on 6/10/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SearchableBalancesVC: BalancesVC {
    var tableViewTopConstraint: NSLayoutConstraint?
    
    lazy var searchContainerView = UIView(backgroundColor: .appWhiteColor)
    var searchBar = CMSearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reset search result
        searchBarDidCancelSearch()
    }
    
    override func viewWillSetUpTableView() {
        layoutSearchBar()
        super.viewWillSetUpTableView()
    }
    
    override func viewDidSetUpTableView() {
        super.viewDidSetUpTableView()
        tableView.removeConstraintToSuperView(withAttribute: .top)
        
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
    }
    
    override func setUp() {
        super.setUp()
        showShadowWhenScrollUp = false
        searchBar.delegate = self
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
        searchContainerView.addSubview(searchBar)
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
    }
    
    func searchBarDidCancelSearch() {
        viewModel.items.accept(viewModel.items.value)
    }
}

extension SearchableBalancesVC: CMSearchBarDelegate {
    func cmSearchBar(_ searchBar: CMSearchBar, searchWithKeyword keyword: String) {
        if keyword.isEmpty {
            searchBarDidCancelSearch()
            return
        }
        let viewModel = self.viewModel as! BalancesViewModel
        viewModel.searchResult.accept(
            viewModel.items.value.filter {($0.name?.lowercased().contains(keyword.lowercased()) ?? false) || $0.symbol.lowercased().contains(keyword.lowercased())}
        )
    }
}
