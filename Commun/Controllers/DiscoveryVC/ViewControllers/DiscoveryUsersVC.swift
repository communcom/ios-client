//
//  DiscoveryUsersVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryUsersVC: SubscriptionsVC {
    init(prefetch: Bool = true) {
        super.init(type: .user, prefetch: prefetch)
        
        defer {
            showShadowWhenScrollUp = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindItems() {
        Observable.merge(
            viewModel.items.asObservable(),
            (viewModel as! SubscriptionsViewModel).searchVM.items
                .map {
                    $0.compactMap{$0.profileValue}
                        .map{ResponseAPIContentGetSubscriptionsItem.user($0)}
                }
        )
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no result".localized().uppercaseFirst
        let description = "try to look for something else".localized().uppercaseFirst
        tableView.addEmptyPlaceholderFooterView(emoji: "😿", title: title, description: description)
    }
    
    // MARK: - Search manager
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SubscriptionsViewModel).searchVM.query = query
        (viewModel as! SubscriptionsViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
