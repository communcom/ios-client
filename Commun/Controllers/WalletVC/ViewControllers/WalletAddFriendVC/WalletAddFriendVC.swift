//
//  CommunWalletAddFriendVC.swift
//  Commun
//
//  Created by Chung Tran on 2/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class WalletAddFriendVC: SubscriptionsVC, WalletAddFriendCellDelegate, SearchableViewControllerType {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    var tableViewTopConstraint: NSLayoutConstraint?
    lazy var searchController = UISearchController.default()
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! SubscriptionsViewModel
        return Observable.merge(
//            viewModel.state.filter {_ in viewModel.searchVM.isQueryEmpty},
            viewModel.searchVM.state.filter {_ in !viewModel.searchVM.isQueryEmpty}
        )
    }
    
    // MARK: - Subviews
    let searchContainerView = UIView(backgroundColor: .white)
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    
    // MARK: - Initializers
    init() {
        super.init(title: "add friends".localized().uppercaseFirst, type: .user, prefetch: false)
        showShadowWhenScrollUp = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseNavigationController?.changeStatusBarStyle(.default)
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.shadowOpacity = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorner()
    }
    
    override func viewWillSetUpTableView() {
        // Search controller
        self.definesPresentationContext = true
        layoutSearchBar()
        
        super.viewWillSetUpTableView()
    }
    
    func layoutSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        searchContainerView.addSubview(searchController.searchBar)
        
        searchController.searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
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
        let viewModel = self.viewModel as! SubscriptionsViewModel
        Observable.merge(
//            viewModel.items.filter {_ in viewModel.searchVM.isQueryEmpty}.asObservable(),
            viewModel.searchVM.items.filter {_ in !viewModel.searchVM.isQueryEmpty}
                .map {
                    $0.compactMap{$0.profileValue}
                        .map{ResponseAPIContentGetSubscriptionsItem.user($0)}
                }
        )
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
    
    private func showSearchBar(onNavigationBar: Bool) {
        if onNavigationBar {
            navigationItem.titleView = searchController.searchBar
            navigationItem.rightBarButtonItem = nil
            
            tableViewTopConstraint?.isActive = false
            
            searchContainerView.removeFromSuperview()
            tableViewTopConstraint = tableView.autoPinEdge(toSuperviewSafeArea: .top)
            
            baseNavigationController?.setNavigationBarBackground()
        } else {
            navigationItem.titleView = nil
            setRightNavBarButton(with: self.closeButton)
            
            tableViewTopConstraint?.isActive = false
            layoutSearchBar()
            tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
            
            baseNavigationController?.setNavigationBarBackground()
        }
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
    
    // MARK: - Search manager
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SubscriptionsViewModel).searchVM.query = query
        (viewModel as! SubscriptionsViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        (viewModel as! SubscriptionsViewModel).searchVM.query = nil
        (viewModel as! SubscriptionsViewModel).searchVM.items.accept([])
        (viewModel as! SubscriptionsViewModel).searchVM.state.accept(.loading(false))
    }
}
