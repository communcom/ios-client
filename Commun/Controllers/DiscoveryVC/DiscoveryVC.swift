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
    // MARK: - Properties
    private weak var currentChildVC: UIViewController?
    var tableView: UITableView? {
        currentChildVC?.view.subviews.first(where: {$0 is UITableView}) as? UITableView
    }
    private var searchWasCancelled = false
    private var searchBarShouldBeginEditting = true
    private var contentViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - ChildVCs
    lazy var searchController = UISearchController.default()
    lazy var suggestionsVC = DiscoverySuggestionsVC(showAllHandler: {
        let originalText = self.searchController.searchBar.text ?? ""
        self.searchController.isActive = false
        self.searchBarChangeTextNotified(text: originalText)
        DispatchQueue.main.async {
            self.setTopBarHidden(false, animated: true)
            if self.topTabBar.selectedIndex.value != 0 {
                self.topTabBar.selectedIndex.accept(0)
            } else {
                self.showChildVCWithIndex(0)
            }
        }
    }) {
        self.searchController.isActive = false
        self.cancelSearch()
    }
    
    lazy var discoveryAllVC = DiscoveryAllVC { index in
        self.topTabBar.selectedIndex.accept(index)
    }
    lazy var communitiesVC = DiscoveryCommunitiesVC(prefetch: self.searchController.searchBar.text?.isEmpty == true)
    lazy var usersVC = DiscoveryUsersVC(prefetch: self.searchController.searchBar.text?.isEmpty == true)
    lazy var postsVC = DiscoveryPostsVC(prefetch: self.searchController.searchBar.text?.isEmpty == true)
    
    // MARK: - Subviews
    lazy var topBarContainerView: UIView = {
        let view = UIView(backgroundColor: .white)
        view.addSubview(topTabBar)
        topTabBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        return view
    }()
    
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
        
        // avoid tabbar
        tableView?.contentInset.bottom = 10 + tabBarHeight
    }
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        // modify view
        view.backgroundColor = .f3f5fa
        
        // search controller
        setUpSearchController()
        
        // contentView
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        setTopBarHidden(false)
    }
    
    private func setUpSearchController() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
    }
    
    private func setTopBarHidden(_ hidden: Bool, animated: Bool = false) {
        if hidden {
            if topBarContainerView.isDescendant(of: view) {
                topBarContainerView.removeFromSuperview()
                
                contentViewTopConstraint?.isActive = false
                contentViewTopConstraint = contentView.autoPinEdge(toSuperviewSafeArea: .top)
            }
        } else {
            if !topBarContainerView.isDescendant(of: view) {
                // top tabBar
                view.addSubview(topBarContainerView)
                topBarContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
                topTabBar.scrollView.contentOffset.x = -16
                
                contentViewTopConstraint?.isActive = false
                contentViewTopConstraint = contentView.autoPinEdge(.top, to: .bottom, of: topBarContainerView)
            }
        }
        
        UIView.animate(withDuration: animated ? 0.3: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        // search controller
        searchController.searchBar.rx.text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { (_) in
                self.searchWasCancelled = false
                if self.currentChildVC != self.suggestionsVC {
                    self.activeSearch()
                }
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { (_) in
                self.searchWasCancelled = true
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.textDidEndEditing
            .subscribe(onNext: { (_) in
                if self.searchWasCancelled {
                    self.cancelSearch()
                }
            })
            .disposed(by: disposeBag)
        
        // topTabBar
        topTabBar.selectedIndex
            .distinctUntilChanged()
            .subscribe(onNext: { (index) in
                self.showChildVCWithIndex(index)
            })
            .disposed(by: disposeBag)
        
        // forward searchBar Delegate
        searchController.searchBar.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func cancelSearch() {
        self.setTopBarHidden(false, animated: true)
        self.showChildVCWithIndex(self.topTabBar.selectedIndex.value)
    }
    
    private func activeSearch() {
        self.setTopBarHidden(true, animated: true)
        self.showChildVC(self.suggestionsVC)
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
            withDuration: 0.2,
            animations: {
                childVC.view.alpha = 1
                oldVC?.view.alpha = 0
            },
            completion: { _ in
                oldVC?.view.removeFromSuperview()
                oldVC?.removeFromParent()
                childVC.didMove(toParent: self)
                
                // assign current childVC
                self.currentChildVC = childVC
                
                // search
                self.search(self.searchController.searchBar.text)
            })
    }
    
    private func addSubview(_ subView: UIView, toView parentView: UIView) {
        parentView.addSubview(subView)
        subView.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: - Actions
    private func search(_ keyword: String?) {
        tableView?.scrollToTop()
        DispatchQueue.main.async {
            if self.searchController.searchBar.isFirstResponder {
                self.suggestionsVC.search(keyword)
            } else {
                self.discoveryAllVC.search(keyword)
                self.communitiesVC.search(keyword)
                self.usersVC.search(keyword)
                self.postsVC.search(keyword)
                
//                switch self.topTabBar.selectedIndex.value {
//                case 0:
//                    self.discoveryAllVC.search(keyword)
//                case 1:
//                    self.communitiesVC.search(keyword)
//                case 2:
//                    self.usersVC.search(keyword)
//                case 3:
//                    self.postsVC.search(keyword)
//                default:
//                    return
//                }
            }
        }
    }
    
    // MARK: - Helpers
    private func searchBarChangeTextNotified(text: String) {
        searchController.searchBar.text = text
        searchController.searchBar.delegate?.searchBar?(searchController.searchBar, textDidChange: text)
    }
}

extension DiscoveryVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder {
            searchBarShouldBeginEditting = false
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let boolToReturn = searchBarShouldBeginEditting
        searchBarShouldBeginEditting = true
        return boolToReturn
    }
}
