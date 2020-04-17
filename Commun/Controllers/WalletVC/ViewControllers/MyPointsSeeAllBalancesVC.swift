//
//  MyPointsSeeAllBalancesVC.swift
//  Commun
//
//  Created by Chung Tran on 3/5/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyPointsSeeAllBalancesVC: BalancesVC, SearchableViewControllerType {
    // MARK: - Properties
    var tableViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    let searchController = UISearchController.default()
    lazy var searchContainerView = UIView(backgroundColor: .appWhiteColor)
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorners()
    }
    
    override func viewWillSetUpTableView() {
        layoutSearchBar()
        super.viewWillSetUpTableView()
    }
    
    func layoutSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        searchContainerView.addSubview(searchBar)
        
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    override func setUpTableView() {
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: tableViewMargin, excludingEdge: .top)
        tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
        
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { (_) in
                self.showSearchBar(onNavigationBar: true)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { (_) in
                self.showSearchBar(onNavigationBar: false)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! BalancesViewModel
        
        Observable.merge(viewModel.items.asObservable(), viewModel.searchResult.filter {$0 != nil}.map {$0!}.asObservable())
            .map {self.mapItems(items: $0)}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func showSearchBar(onNavigationBar: Bool) {
        if onNavigationBar {
            navigationItem.titleView = searchBar
            navigationItem.rightBarButtonItem = nil
            
            tableViewTopConstraint?.isActive = false
            
            searchContainerView.removeFromSuperview()
            tableViewTopConstraint = tableView.autoPinEdge(toSuperviewSafeArea: .top)
            
            resetNavigationBar()
        } else {
            navigationItem.titleView = nil
            setRightNavBarButton(with: self.closeButton)
            
            tableViewTopConstraint?.isActive = false
            layoutSearchBar()
            tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
            
            resetNavigationBar()
        }
    }
    
    private func resetNavigationBar() {
        let img = UIImage()
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .appWhiteColor
        navigationController?.navigationBar.subviews.first?.backgroundColor = .appWhiteColor
    }
    
    // MARK: - Search manager
    func searchBarIsSearchingWithQuery(_ query: String) {
        let viewModel = self.viewModel as! BalancesViewModel
        viewModel.searchResult.accept(
            viewModel.items.value.filter {($0.name?.lowercased().contains(query.lowercased()) ?? false) || $0.symbol.lowercased().contains(query.lowercased())}
        )
    }
    
    func searchBarDidCancelSearching() {
        viewModel.items.accept(viewModel.items.value)
    }
}
