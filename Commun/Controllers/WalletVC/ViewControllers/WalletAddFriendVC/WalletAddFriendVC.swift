//
//  CommunWalletAddFriendVC.swift
//  Commun
//
//  Created by Chung Tran on 2/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class WalletAddFriendVC: SubsViewController<ResponseAPIContentSearchItem, WalletAddFriendCell>, WalletAddFriendCellDelegate, SearchableViewControllerType {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    var tableViewTopConstraint: NSLayoutConstraint?
    lazy var searchController = UISearchController.default()
    
    // MARK: - Subviews
    let searchContainerView = UIView(backgroundColor: .white)
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    
    // MARK: - Initializers
    init() {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).limit = 20
        (vm.fetcher as! SearchListFetcher).searchType = .entitySearch
        (vm.fetcher as! SearchListFetcher).entitySearchEntity = .profiles
        super.init(viewModel: vm)
        showShadowWhenScrollUp = false
        title = String(format: "%@ %@", "add".localized().uppercaseFirst, "friends".localized())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.shadowOpacity = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorners()
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
    
    override func configureCell(with item: ResponseAPIContentSearchItem, indexPath: IndexPath) -> UITableViewCell {
        if let profile = item.profileValue {
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
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.subviews.first?.backgroundColor = .white
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
        (viewModel as! SearchViewModel).query = query
        viewModel.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.state.accept(.listEnded)
        viewModel.items.accept([])
    }
}
