//
//  SearchablePostsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SearchablePostsVC: PostsViewController {
    override var isSearchEnabled: Bool {true}
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
        if let keyword = initialKeyword {
            searchBarChangeTextNotified(text: "")
            searchBarChangeTextNotified(text: keyword)
        }
    }
    
    private func searchBarChangeTextNotified(text: String) {
        searchController.searchBar.text = text
        searchController.searchBar.delegate?.searchBar?(searchController.searchBar, textDidChange: text)
    }
    
    override func bindItems() {
        viewModel.items
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func search(_ keyword: String?) {
        viewModel.rowHeights = [:]
        super.search(keyword)
    }
}
