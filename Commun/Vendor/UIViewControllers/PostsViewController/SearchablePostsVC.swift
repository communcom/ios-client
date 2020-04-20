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
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! PostsViewModel
        return Observable.merge(
            viewModel.state.filter {_ in viewModel.searchVM.isQueryEmpty},
            viewModel.searchVM.state.filter {_ in !viewModel.searchVM.isQueryEmpty}
        )
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.roundCorner()
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
        searchBar.sizeToFit()
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
        
        tableView.rx.contentOffset
            .map {$0.y > 3}
            .distinctUntilChanged()
            .subscribe(onNext: { (show) in
                self.navigationController?.navigationBar.showShadow(show)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        Observable.merge(
            viewModel.items.asObservable(),
            (viewModel as! PostsViewModel).searchVM.items.map{$0.compactMap{$0.postValue}}
        )
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .do(onNext: { (items) in
                if items.count == 0 {
                    self.handleListEmpty()
                }
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        viewModel.rowHeights = [:]
        (viewModel as! PostsViewModel).searchVM.query = query
        (viewModel as! PostsViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.rowHeights = [:]
        (viewModel as! PostsViewModel).searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
