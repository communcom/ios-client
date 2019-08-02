//
//  CommunitiesVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension CommunitiesVC {
    // MARK: - bind UI
    func bindUI() {
        // bind search text to filter
        searchBar.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.viewModel.applyFilter(text: text)
            })
            .disposed(by: bag)
        
        // bind items to datasource
        Observable.combineLatest(viewModel.items, viewModel.filter)
            .map {items, filter in
                var filteredByText = items
                let filter = self.viewModel.filter.value
                
                // filter by text result
                if let text = filter.text {
                    filteredByText = filteredByText.filter {$0.name.lowercased().contains(text.lowercased())}
                }
                
                // filter by joined
                var myCommunities = [MockupCommunity]()
                var recommendedCommunities = [MockupCommunity]()
                
                if let joined = filter.joined {
                    if joined {
                        myCommunities = filteredByText.filter {$0.joined}
                    } else {
                        recommendedCommunities = filteredByText.filter {!$0.joined}
                    }
                } else {
                    myCommunities = filteredByText.filter {$0.joined}
                    recommendedCommunities = filteredByText.filter {!$0.joined}
                }
                
                return [
                    Section(model: "Recommended", items: recommendedCommunities),
                    Section(model: "", items: myCommunities)
                ]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // forward delegate to set section for header
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
}
