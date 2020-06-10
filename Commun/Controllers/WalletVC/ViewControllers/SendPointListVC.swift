//
//  SendPointListVC.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SendPointListVC: SubscriptionsVC, SearchableViewControllerType {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    var tableViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var searchContainerView = UIView(backgroundColor: .appWhiteColor)
    var searchBar = UISearchBar.default()
    
    // MARK: - Initializers
    init() {
        super.init(title: "send points".localized().uppercaseFirst, type: .user)
        showShadowWhenScrollUp = false
        searchBar.showsCancelButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarDidCancelSearching()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.roundCorner()
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
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        layoutSearchBar()
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.removeConstraintToSuperView(withAttribute: .top)
        
        tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchBar)
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
            .do(onNext: { (items) in
                if items.count == 0 {
                    self.handleListEmpty()
                }
            })
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
    
    func layoutSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        searchContainerView.addSubview(searchBar)
        
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SubscriptionsViewModel).searchVM.query = query
        (viewModel as! SubscriptionsViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        (viewModel as! SubscriptionsViewModel).searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
