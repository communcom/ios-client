//
//  SearchableViewControllerType.swift
//  Commun
//
//  Created by Chung Tran on 2/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchableViewControllerType: BaseViewController {
    var searchBar: UISearchBar {get set}
    func layoutSearchBar()
    func searchBarIsSearchingWithQuery(_ query: String)
    func searchBarDidCancelSearching()
}

extension SearchableViewControllerType {
    func bindSearchBar() {
        searchBar.rx.text
            .distinctUntilChanged()
            .skip(searchBar.text?.isEmpty == false ? 0 : 1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)
    }
    
    private func search(_ keyword: String?) {
        if let keyword = keyword, !keyword.isEmpty {
            searchBarIsSearchingWithQuery(keyword)
        } else {
            searchBarDidCancelSearching()
        }
    }
}
