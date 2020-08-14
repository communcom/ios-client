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
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.embeded}
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! SubscriptionsViewModel
        return Observable.merge(
            viewModel.state.filter {_ in viewModel.searchVM.isQueryEmpty},
            viewModel.searchVM.state.filter {_ in !viewModel.searchVM.isQueryEmpty}
        )
    }
    
    init(prefetch: Bool = true) {
        super.init(type: .user, prefetch: prefetch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setUp() {
        super.setUp()
        refreshControl.subviews.first?.bounds.origin.y = 15
        showShadowWhenScrollUp = false
    }

    override func bindItems() {
        let viewModel = self.viewModel as! SubscriptionsViewModel
        Observable.merge(
            viewModel.items.filter {_ in viewModel.searchVM.isQueryEmpty}.asObservable(),
            viewModel.searchVM.items.filter {_ in !viewModel.searchVM.isQueryEmpty}
                .map {
                    $0.compactMap{$0.profileValue}
                        .map{ResponseAPIContentGetSubscriptionsItem.user($0)}
                }
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
        (viewModel as! SubscriptionsViewModel).searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
