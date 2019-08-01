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
                if text.count == 0 {
                    // Reset filter
                    self.viewModel.filter.accept(self.segmentio.selectedSegmentioIndex == 0 ? .myCommunities : .discover)
                    self.segmentioHeightConstraint.constant = 52
                    self.segmentio.isHidden = false
                    return
                }
                self.segmentioHeightConstraint.constant = 0
                self.segmentio.isHidden = true
                self.viewModel.filter.accept(.search(text: text))
            })
            .disposed(by: bag)
        
        // bind items to datasource
        Observable.combineLatest(viewModel.items, viewModel.filter)
            .map {items, filter in
                var myCommunities = [MockupCommunity]()
                var recommendedCommunities = [MockupCommunity]()
                switch filter {
                case .myCommunities:
                    myCommunities = items.filter {$0.joined}
                case .discover:
                    recommendedCommunities = items.filter {!$0.joined}
                case .search(let text):
                    let filteredItems = items.filter {$0.name.lowercased().contains(text.lowercased())}
                    myCommunities = filteredItems.filter {$0.joined}
                    recommendedCommunities = filteredItems.filter {!$0.joined}
                }
                
                return [
                    Section(model: "", items: myCommunities),
                    Section(model: "Recommended", items: recommendedCommunities)
                ]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // forward delegate to set section for header
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
}
