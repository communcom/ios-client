//
//  SearchablePostsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SearchablePostsVC: PostsViewController, SearchableViewControllerType {
    var searchVM: SearchViewModel {
        (viewModel as! PostsViewModel).searchVM
    }
    lazy var searchBar = UISearchBar.default()
    
    private var initialKeyword: String?
    
    init(keyword: String? = nil) {
        self.initialKeyword = keyword
        super.init(prefetch: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        layoutSearchBar()
        
        if let keyword = initialKeyword {
            searchBar.changeTextNotified(text: "")
            searchBar.changeTextNotified(text: keyword)
        }
    }
    
    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchBar
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
    }
    
    override func bindItems() {
        Observable.merge(
            viewModel.items.asObservable(),
            searchVM.items.map{$0.compactMap{$0.postValue}}
        )
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        viewModel.rowHeights = [:]
        searchVM.query = query
        searchVM.reload()
    }
    
    func searchBarDidCancelSearching() {
        viewModel.items.accept(viewModel.items.value)
    }
}
