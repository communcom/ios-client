//
//  DiscoveryVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoverySearchBarStackView: UIStackView {
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
class DiscoveryVC: BaseViewController, SearchableViewControllerType {
    
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
        self.searchBar.changeTextNotified(text: originalText)
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
        let view = UIView(backgroundColor: .appWhiteColor)
        view.addSubview(topTabBar)
        topTabBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0))
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
        contentInset: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    )
    
    lazy var contentView = UIView(forAutoLayout: ())
    
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    
    lazy var searchBarContainerView: DiscoverySearchBarStackView = {
        let stackView = DiscoverySearchBarStackView(axis: .horizontal, spacing: 8, alignment: .fill, distribution: .fill)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubviews([searchBar, plusButton])
        return stackView
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton.circle(size: 35, backgroundColor: .clear, imageName: "add-community")
        button.addTarget(self, action: #selector(plusButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchController.roundCorners()
        navigationController?.navigationBar.shadowOpacity = 0
        
        // avoid tabbar
        tableView?.contentInset.bottom = 10 + tabBarHeight
    }
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        
        // modify view
        view.backgroundColor = .appLightGrayColor
        
        // search controller
        layoutSearchBar()
        
        // contentView
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        setTopBarHidden(false)
        
        searchBarContainerView.layoutIfNeeded()
        plusButton.isHidden = true
    }
    
    func layoutSearchBar() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchBarContainerView
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
                topTabBar.scrollView.contentOffset.x = -10
                
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
        bindSearchBar()
        
        searchController.searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { (_) in
                self.searchWasCancelled = false
                if self.currentChildVC != self.suggestionsVC {
                    self.activeSearch()
                }
                self.plusButton.isHidden = true
                self.searchBarContainerView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { (_) in
                self.searchWasCancelled = true
                self.plusButton.isHidden = self.topTabBar.selectedIndex.value != 1
                self.searchBarContainerView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.textDidEndEditing
            .subscribe(onNext: { (_) in
                if self.searchWasCancelled {
                    self.cancelSearch()
                }
                self.plusButton.isHidden = self.topTabBar.selectedIndex.value != 1
                self.searchBarContainerView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        // topTabBar
        topTabBar.selectedIndex
            .distinctUntilChanged()
            .subscribe(onNext: { (index) in
                self.showChildVCWithIndex(index)
                UIView.animate(withDuration: 0.3) {
                    self.searchBarContainerView.layoutIfNeeded()
                    self.plusButton.isHidden = index != 1
                    self.searchBarContainerView.layoutIfNeeded()
                }
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
    
    private func showChildVC(_ newVC: UIViewController) {
        // search
        self.search(self.searchController.searchBar.text)
        
        // get oldVC
        guard let oldVC = currentChildVC else {
            addChild(newVC)
            contentView.addSubview(newVC.view)
            newVC.view.autoPinEdgesToSuperviewEdges()
            newVC.didMove(toParent: self)
            
            // assign current childVC
            self.currentChildVC = newVC
            return
        }
        
        // move oldVC out
        oldVC.willMove(toParent: nil)
        
        // add newVC
        addChild(newVC)
        contentView.insertSubview(newVC.view, belowSubview: oldVC.view)
        newVC.view.autoPinEdgesToSuperviewEdges()
        
        // Transtion
        UIView.transition(from: oldVC.view, to: newVC.view, duration: 0.3, options: [.transitionCrossDissolve]) { (_) in
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
            
            // assign current childVC
            self.currentChildVC = newVC
        }
    }
    
    // MARK: - Search manager
    private func search(_ keyword: String?) {
        tableView?.scrollToTop()
        DispatchQueue.main.async {
            if let keyword = keyword, !keyword.isEmpty {
                self.searchBarIsSearchingWithQuery(keyword)
            } else {
                self.searchBarDidCancelSearching()
            }
        }
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
//        if self.searchController.searchBar.isFirstResponder {
            self.suggestionsVC.searchBarIsSearchingWithQuery(query)
//        } else {
            self.discoveryAllVC.searchBarIsSearchingWithQuery(query)
            self.communitiesVC.searchBarIsSearchingWithQuery(query)
            self.usersVC.searchBarIsSearchingWithQuery(query)
            self.postsVC.searchBarIsSearchingWithQuery(query)
//        }
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
    
    func searchBarDidCancelSearching() {
//        if self.searchController.searchBar.isFirstResponder {
            self.suggestionsVC.searchBarDidCancelSearching()
//        } else {
            self.discoveryAllVC.searchBarDidCancelSearching()
            self.communitiesVC.searchBarDidCancelSearching()
            self.usersVC.searchBarDidCancelSearching()
            self.postsVC.searchBarDidCancelSearching()
//        }
    }
    
    @objc func plusButtonDidTouch() {
        present(CreateCommunityGettingStartedVC(), animated: true, completion: nil)
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
