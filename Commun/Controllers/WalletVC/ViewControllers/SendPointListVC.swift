//
//  SendPointListVC.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SendPointListVC: SubscriptionsVC {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! SubscriptionsViewModel
        return Observable.merge(
            viewModel.state.filter {_ in viewModel.searchVM.isQueryEmpty},
            viewModel.searchVM.state.filter {_ in !viewModel.searchVM.isQueryEmpty}
        )
    }
    
    // MARK: - Subviews
    lazy var searchContainerView = UIView(backgroundColor: .appWhiteColor)
    var searchBar = CMSearchBar()
    
    // MARK: - Initializers
    init() {
        super.init(title: "send points".localized().uppercaseFirst, type: .user)
        showShadowWhenScrollUp = false
        searchBar.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarDidCancelSearch()
    }
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        layoutSearchBar()
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.removeConstraintToSuperView(withAttribute: .top)
        
        tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! SubscriptionsViewModel
        Observable.merge(
            viewModel.items.filter {_ in viewModel.searchVM.isQueryEmpty}.asObservable(),
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
    
    override func configureCell(with subscription: ResponseAPIContentGetSubscriptionsItem, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: subscription, indexPath: indexPath) as! SubscriptionsUserCell
        cell.hideActionButton()
        return cell
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetSubscriptionsItem) {
        guard let user = item.userValue else {return}
        self.completion?(user)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Search manager
    func layoutSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        searchContainerView.addSubview(searchBar)
        
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarDidCancelSearch() {
        (viewModel as! SubscriptionsViewModel).searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(viewModel.state.value)
    }
}

extension SendPointListVC: CMSearchBarDelegate {
    func cmSearchBar(_ searchBar: CMSearchBar, searchWithKeyword keyword: String) {
        if keyword.isEmpty {
            searchBarDidCancelSearch()
            return
        }
        (viewModel as! SubscriptionsViewModel).searchVM.query = keyword
        (viewModel as! SubscriptionsViewModel).searchVM.reload(clearResult: false)
    }
    
    func cmSearchBarDidBeginSearching(_ searchBar: CMSearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func cmSearchBarDidEndSearching(_ searchBar: CMSearchBar) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func cmSearchBarDidCancelSearching(_ searchBar: CMSearchBar) {
        searchBar.clear()
    }
}
