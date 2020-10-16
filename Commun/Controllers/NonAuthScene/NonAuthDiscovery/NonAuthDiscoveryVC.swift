//
//  NonAuthDiscoveryVC.swift
//  Commun
//
//  Created by Chung Tran on 7/21/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthDiscoveryVC: BaseViewController, SearchableViewControllerType, NonAuthVCType {
    // MARK: - Properties
    private weak var currentChildVC: UIViewController?
    private var searchWasCancelled = false
    private var searchBarShouldBeginEditting = true
    
    // MARK: - ChildVCs
    lazy var communitiesVC = NonAuthCommunitiesVC()
    lazy var suggestionsVC = NonAuthSuggestionsVC(showAllHandler: {
        
    }) {
        self.searchController.isActive = false
        self.cancelSearch()
    }
    
    // MARK: - Subviews
    lazy var searchController = UISearchController.default()
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    lazy var contentView = UIView(forAutoLayout: ())
    var tableView: UITableView? {
        currentChildVC?.view.subviews.first(where: {$0 is UITableView}) as? UITableView
    }
    
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
        contentView.autoPinEdgesToSuperviewEdges(with: .zero)
        
        // kick off communitiesVC
        showChildVC(communitiesVC)
    }
    
    func layoutSearchBar() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchBar
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
    }
    
    private func cancelSearch() {
        showChildVC(communitiesVC)
    }
    
    private func activeSearch() {
        showChildVC(suggestionsVC)
    }
    
    // MARK: - ChildVC manager
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
        self.suggestionsVC.searchBarIsSearchingWithQuery(query)
    }
    
    func searchBarDidCancelSearching() {
        self.suggestionsVC.searchBarDidCancelSearching()
    }
}

extension NonAuthDiscoveryVC: UISearchBarDelegate {
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
