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
    
    // MARK: - ChildVCs
    lazy var searchController = UISearchController.default()
    
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
    }
    
    private func setUpSearchController() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func search(_ keyword: String?) {
        if let keyword = keyword, !keyword.isEmpty {
            // search by keyword
            
        } else {
            // back to discovery
        }
    }
}
