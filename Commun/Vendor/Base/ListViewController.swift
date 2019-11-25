//
//  ListViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class ListViewController<T: ListItemType>: BaseViewController {
    // MARK: - Nested type
    public typealias ListSection = AnimatableSectionModel<String, T>
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ListViewModel<T>!
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<ListSection>!
    var tableViewMargin: UIEdgeInsets {.zero}
    
    // Search manager
    var isSearchEnabled: Bool {false}
    var searchPlaceholder: String? {nil}
    lazy var searchController: UISearchController? = {
        if !isSearchEnabled {return nil}
        return UISearchController(searchResultsController: nil)
    }()
    
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: tableViewMargin)
        return tableView
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // searchController
        if isSearchEnabled {
            // searchController
            searchController?.obscuresBackgroundDuringPresentation = false
            searchController?.searchBar.placeholder = searchPlaceholder ?? "search".localized().uppercaseFirst
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
        
        // pull to refresh
        tableView.es.addPullToRefresh { [unowned self] in
            self.tableView.es.stopPullToRefresh()
            self.refresh()
        }
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        bindState()
        bindItems()
        
        if isSearchEnabled {
            bindSearchController()
        }
    }
    
    func bindItems() {
        viewModel.items
            .map {[ListSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func bindState() {
        viewModel.state
            .do(onNext: { (state) in
                Logger.log(message: "\(state)", event: .debug)
                return
            })
            .subscribe(onNext: {[weak self] state in
                switch state {
                case .loading(let isLoading):
                    self?.handleLoading(isLoading: isLoading)
                case .listEnded:
                    self?.handleListEnded()
                case .listEmpty:
                    self?.handleListEmpty()
                case .error(_):
                    self?.handleListError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindSearchController() {
        searchController?.searchBar.rx.text.orEmpty
            .skip(1)
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest {Observable<String>.just($0)}
            .subscribe(onNext: { (query) in
                if query.isEmpty {
                    self.viewModel.fetcher.search = nil
                    self.viewModel.reload()
                    return
                }
                
                self.viewModel.fetcher.search = query
                self.viewModel.reload()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - State handling
    func handleLoading(isLoading: Bool) {
        if isLoading {
            showLoadingFooter()
        }
        else {
            tableView.tableFooterView = UIView()
        }
    }
    
    func showLoadingFooter() {
        tableView.addLoadingFooterView(
            rowType:        PlaceholderNotificationCell.self,
            tag:            notificationsLoadingFooterViewTag,
            rowHeight:      88,
            numberOfRows:   1
        )
    }
    
    func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    func handleListEmpty() {
        tableView.tableFooterView = UIView()
    }
    
    func handleListError() {
        let title = "error"
        let description = "there is an error occurs"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst, buttonLabel: "retry".localized().uppercaseFirst)
        {
            self.viewModel.fetchNext(forceRetry: true)
        }
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
}
