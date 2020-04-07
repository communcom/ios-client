//
//  MyProfileBlacklistVC.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileBlacklistVC: BaseViewController {
    // MARK: - Properties
    let viewModel: MyProfileBlacklistViewModel
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    
    // MARK: - Subviews
    
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: MyProfileBlacklistViewModel.SegmentedItem.allCases.map {$0.rawValue.localized().uppercaseFirst},
        selectedIndex: 0)
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    // MARK: - Initializers
    init() {
        self.viewModel = MyProfileBlacklistViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.addShadow(ofColor: .clear, opacity: 0)
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my blacklist".localized().uppercaseFirst
        setLeftNavBarButtonForGoingBack()
        
        edgesForExtendedLayout = .all
        view.backgroundColor = .f3f5fa
        
        let topBarContainerView = UIView(height: 55, backgroundColor: .white)
        view.addSubview(topBarContainerView)
        topBarContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        topBarContainerView.addSubview(topTabBar)
        topTabBar.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        topTabBar.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        topTabBar.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        // tableView
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: topBarContainerView)
        
        tableView.backgroundColor = .f3f5fa
        tableView.register(BlacklistCell.self, forCellReuseIdentifier: "BlacklistCell")
        
        tableView.separatorStyle = .none
        
        // pull to refresh
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = .appGrayColor
    }

    @objc func refresh() {
        reload()
        refreshControl.endRefreshing()
    }
    
    override func bind() {
        super.bind()
        // tabBar's selection changed
        bindSegmentedControl()
        
        // list loading state
        bindState()
        
        bindList()
    }
    
    func handleListLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        switch viewModel.segmentedItem.value {
        case .users:
            title = "no users"
            description = "no blocked users found"
        case .communities:
            title = "no communities"
            description = "no blocked communities found"
        }
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    func handleListError() {
        let title = "error"
        let description = "there is an error occurs"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst, buttonLabel: "retry".localized().uppercaseFirst) {
            self.viewModel.fetchNext(forceRetry: true)
        }
    }
    
    @objc func reload() {
        viewModel.reload()
        viewModel.fetchNext(forceRetry: true)
    }
}
