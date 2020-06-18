//
//  SearchBarTestVC.swift
//  Commun
//
//  Created by Chung Tran on 6/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SearchBarTestVC: BaseViewController {

    let searchBar = CMSearchBar()
    override func setUp() {
        super.setUp()
        title = "fuck"
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), excludingEdge: .bottom)
    }
    
    func placeSearchBar(onNavigationBar: Bool) {
        navigationController?.setNavigationBarHidden(onNavigationBar, animated: true)
    }
}

extension SearchBarTestVC: CMSearchBarDelegate {
    func cmSearchBar(_ searchBar: CMSearchBar, searchWithKeyword keyword: String) {
        print(keyword)
    }
    
    func cmSearchBarDidBeginSearching(_ searchBar: CMSearchBar) {
        placeSearchBar(onNavigationBar: true)
    }
    
    func cmSearchBarDidEndSearching(_ searchBar: CMSearchBar) {
        placeSearchBar(onNavigationBar: false)
    }
}
