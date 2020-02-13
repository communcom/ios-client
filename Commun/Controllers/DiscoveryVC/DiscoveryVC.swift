//
//  DiscoveryVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryVC: BaseViewController {
    // MARK: - Nested types
    class DiscoveryCommunitiesVC: CommunitiesVC {
        override var showShadowWhenScrollUp: Bool {false}
    }

    class DiscoverySubscribersVC: SubscribersVC {
        override var showShadowWhenScrollUp: Bool {false}
    }
    
    // MARK: - Properties
    weak var currentChildVC: UIViewController?
    var tableView: UITableView? {
        currentChildVC?.view.subviews.first(where: {$0 is UITableView}) as? UITableView
    }
    
    // MARK: - ChildVCs
    lazy var searchController = UISearchController.default()
    lazy var discoveryAllVC = DiscoveryAllVC()
    lazy var communitiesVC = DiscoveryCommunitiesVC(type: .all)
    lazy var usersVC = DiscoverySubscribersVC(userId: Config.currentUser?.id)
    lazy var postsVC = PostsViewController(filter: PostsListFetcher.Filter(feedTypeMode: .subscriptionsPopular, feedType: .time, sortType: .day, userId: Config.currentUser?.id))
    
    // MARK: - Subviews
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: [
            "all".localized().uppercaseFirst,
            "communities".localized().uppercaseFirst,
            "users".localized().uppercaseFirst,
            "posts".localized().uppercaseFirst
        ],
        selectedIndex: 0,
        contentInset: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    )
    
    lazy var contentView = UIView(forAutoLayout: ())
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        baseNavigationController?.resetNavigationBar()
        baseNavigationController?.changeStatusBarStyle(.default)
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorner()
        navigationController?.navigationBar.shadowOpacity = 0
    }
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        // modify view
        view.backgroundColor = .f3f5fa
        
        // search controller
        setUpSearchController()
        
        // top tabBar
        let topBarContainerView: UIView = {
            let view = UIView(backgroundColor: .white)
            view.addSubview(topTabBar)
            topTabBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
            return view
        }()
        view.addSubview(topBarContainerView)
        topBarContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        topTabBar.scrollView.contentOffset.x = -16
        
        // contentView
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        contentView.autoPinEdge(.top, to: .bottom, of: topBarContainerView)
    }
    
    private func setUpSearchController() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        // search controller
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)
        
        // topTabBar
        topTabBar.selectedIndex
            .distinctUntilChanged()
            .subscribe(onNext: { (index) in
                self.showChildVCWithIndex(index)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - ChildVC manager
    private func showChildVCWithIndex(_ index: Int) {
        let vc: UIViewController
        
        // select vc
        switch index {
        case 0:
            // All
            vc = discoveryAllVC
        case 1:
            // Community
            vc = communitiesVC
        case 2:
            // Users
            vc = usersVC
        case 3:
            // Posts
            vc = postsVC
        default:
            return
        }
        
        // show as child
        showChildVC(vc)
    }
    
    private func showChildVC(_ childVC: UIViewController) {
        // get oldVC
        let oldVC = currentChildVC
        
        // move oldVC out
        oldVC?.willMove(toParent: nil)
        addChild(childVC)
        self.addSubview(childVC.view, toView: contentView)
        childVC.view.alpha = 0
        childVC.view.layoutIfNeeded()
        UIView.animate(
            withDuration: 0.5,
            animations: {
                childVC.view.alpha = 1
                oldVC?.view.alpha = 0
            },
            completion: { _ in
                oldVC?.view.removeFromSuperview()
                oldVC?.removeFromParent()
                childVC.didMove(toParent: self)
            })
        // assign current childVC
        currentChildVC = childVC
        
        // scroll to top
        tableView?.scrollToTop()
    }
    
    private func addSubview(_ subView: UIView, toView parentView: UIView) {
        parentView.addSubview(subView)
        subView.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: - Actions
    private func search(_ keyword: String?) {
        if let keyword = keyword, !keyword.isEmpty {
            // TODO: - search by keyword
            
        } else {
            // TODO: - back to discovery
        }
    }
}
