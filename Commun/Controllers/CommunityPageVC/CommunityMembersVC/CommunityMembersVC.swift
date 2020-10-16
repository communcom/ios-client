//
//  CommunityMembersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class CommunityMembersVC: BaseViewController, LeaderCellDelegate, ProfileCellDelegate, HasLeadersVM {
    // MARK: - Nested type
    enum CustomElementType: IdentifiableType, Equatable {
        case subscriber(ResponseAPIContentGetProfile)
        case leader(ResponseAPIContentGetLeader)
        case bannedUser(ResponseAPIContentGetProfile)
        
        var identity: String {
            switch self {
            case .subscriber(let subscriber):
                return "subscriber/" + subscriber.identity
            case .leader(let leader):
                return "leader/" + leader.identity
            case .bannedUser(let user):
                return "bannedUser/" + user.identity
            }
        }
    }
    
    // MARK: - Properties
    var selectedSegmentedItem: CommunityMembersViewModel.SegmentedItem
    var viewModel: CommunityMembersViewModel
    var leadersVM: LeadersViewModel { viewModel.leadersVM }
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    
    // MARK: - Subviews
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: CommunityMembersViewModel.SegmentedItem.allCases
            .filter {viewModel.community.isLeader == true ? true: $0 != .banned}
            .map {$0.rawValue.localized().uppercaseFirst},
        selectedIndex: selectedSegmentedItem.index,
        contentInset: UIEdgeInsets(horizontal: 32, vertical: 0)
    )
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    lazy var headerView = CommunityMembersHeaderView(height: 268)
    
    // MARK: - Initializers
    init(community: ResponseAPIContentGetCommunity, selectedSegmentedItem: CommunityMembersViewModel.SegmentedItem) {
        self.selectedSegmentedItem = selectedSegmentedItem
        self.viewModel = CommunityMembersViewModel(community: community, starterSegmentedItem: selectedSegmentedItem)
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
        title = viewModel.community.name
        setLeftNavBarButtonForGoingBack()

        edgesForExtendedLayout = .all
        view.backgroundColor = .appLightGrayColor
        
        let topBarContainerView = UIView(height: 55, backgroundColor: .appWhiteColor)
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
        
        tableView.backgroundColor = .appLightGrayColor
        tableView.register(CommunityMemberCell.self, forCellReuseIdentifier: "CommunityMemberCell")
        tableView.register(CommunityBannedUserCell.self, forCellReuseIdentifier: "CommunityBannedUserCell")
        tableView.register(CommunityLeaderFollowCell.self, forCellReuseIdentifier: "CommunityLeaderFollowCell")
        
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
        
        bindScrollView()
        
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
        case .all:
            title = "no members"
            description = "members not found"
        case .leaders:
            title = "no leaders"
            description = "leaders not found"
        case .friends:
            title = "no friends"
            description = "friends not found"
        case .banned:
            title = "no banned users"
            description = "banned users not found"
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
