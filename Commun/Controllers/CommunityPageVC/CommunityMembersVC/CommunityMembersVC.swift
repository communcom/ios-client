//
//  CommunityMembersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommunityMembersVC: BaseViewController {
    // MARK: - Properties
    var selectedSegmentedItem: CommunityMembersViewModel.SegmentedItem
    let disposeBag = DisposeBag()
    var viewModel: CommunityMembersViewModel
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 24))
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: CommunityMembersViewModel.SegmentedItem.allCases.map {$0.rawValue},
        selectedIndex: selectedSegmentedItem.index)
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    // MARK: - Initializers
    init(community: ResponseAPIContentGetCommunity, selectedSegmentedItem: CommunityMembersViewModel.SegmentedItem) {
        self.selectedSegmentedItem = selectedSegmentedItem
        self.viewModel = CommunityMembersViewModel(community: community, starterSegmentedItem: selectedSegmentedItem)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        setLeftNavBarButton(with: backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        edgesForExtendedLayout = .all
        view.backgroundColor = .f3f5fa
        
        let topBarContainerView = UIView(height: 55, backgroundColor: .white)
        view.addSubview(topBarContainerView)
        topBarContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        topBarContainerView.addSubview(topTabBar)
        topTabBar.autoPinEdge(toSuperviewEdge: .leading)
        topTabBar.autoPinEdge(toSuperviewEdge: .trailing)
        topTabBar.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        // tableView
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: topBarContainerView)
        
        tableView.backgroundColor = .f3f5fa
        tableView.register(SubscribersCell.self, forCellReuseIdentifier: "SubscribersCell")
        tableView.register(CommunityLeaderCell.self, forCellReuseIdentifier: "CommunityLeaderCell")
        
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
    }
    
    @objc func reload() {
        viewModel.reload()
        viewModel.fetchNext(forceRetry: true)
    }
}
