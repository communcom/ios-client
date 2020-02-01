//
//  SearchViewController.swift
//  Commun
//
//  Created by Chung Tran on 2/1/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewController: BaseViewController {
    // MARK: - Properties
    lazy var searchController = UISearchController.default()
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorner()
    }
    
    override func setUp() {
        super.setUp()
        setUpSearchController()
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
    }
    
    func bindSearchBar() {
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)

    }
    
    private func setUpSearchController() {
        self.definesPresentationContext = true
        layoutSearchBar()
    }
    
    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
    }
    
    func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            // TODO: - Cancel search
            return
        }
        
        // TODO: - do search
    }
}
