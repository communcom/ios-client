//
//  DiscoveryCommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryCommunitiesVC: CommunitiesVC {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.embeded}
    
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! CommunitiesViewModel
        return viewModel.mergedState
    }
    
    convenience init(prefetch: Bool) {
        self.init(type: .all, prefetch: prefetch)
        defer {
            showShadowWhenScrollUp = false
        }
    }

    override func setUp() {
        super.setUp()
        refreshControl.subviews.first?.bounds.origin.y = 15
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! CommunitiesViewModel
        viewModel.mergedItems
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
        (viewModel as! CommunitiesViewModel).searchVM.query = query
        (viewModel as! CommunitiesViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        (viewModel as! CommunitiesViewModel).searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
