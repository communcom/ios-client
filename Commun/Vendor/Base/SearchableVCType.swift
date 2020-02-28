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
    var searchController: UISearchController {get set}
    func layoutSearchBar()
    func search(_ keyword: String?)
}

extension SearchableViewControllerType {
    func setUpSearchController() {
        self.definesPresentationContext = true
        layoutSearchBar()
    }
    
    func bindSearchBar() {
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .skip(searchController.searchBar.text?.isEmpty == false ? 0 : 1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)
    }
}
