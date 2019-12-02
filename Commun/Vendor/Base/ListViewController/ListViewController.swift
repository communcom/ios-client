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

class ListViewController<T: ListItemType, CellType: ListItemCellType>: BaseViewController {
    // MARK: - Nested type
    public typealias ListSection = AnimatableSectionModel<String, T>
    
    // MARK: - Properties
    var viewModel: ListViewModel<T>
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
    
    // MARK: - Initializers
    init(viewModel: ListViewModel<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        // registerCell
        registerCell()
        
        // set up datasource
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                var cell = self.configureCell(with: item, indexPath: indexPath)
                (cell as? CellType)?.delegate = self as? CellType.Delegate
                return cell
            }
        )
    }
    
    func registerCell() {
        tableView.register(CellType.self, forCellReuseIdentifier: String(describing: CellType.self))
    }
    
    func configureCell(with item: T, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: CellType.self)) as! CellType
        cell.setUp(with: item as! CellType.T)
        
        return cell as! UITableViewCell
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        bindState()
        bindItems()
        bindItemSelected()
        bindScrollView()
        
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
    
    func bindItemSelected() {
        tableView.rx.modelSelected(T.self)
            .subscribe(onNext: { (item) in
                self.modelSelected(item)
            })
            .disposed(by: disposeBag)
    }
    
    func modelSelected(_ item: T) {
        if let post = item as? ResponseAPIContentGetPost {
            let postPageVC = PostPageVC(post: post)
            show(postPageVC, sender: nil)
            return
        }
        
        if let item = item as? ResponseAPIContentGetSubscriptionsItem {
            if let community = item.communityValue {
                showCommunityWithCommunityId(community.communityId)
            }
            if let user = item.userValue {
                showProfileWithUserId(user.userId)
            }
            return
        }
        
        if let community = item as? ResponseAPIContentGetCommunity {
            showCommunityWithCommunityId(community.communityId)
            return
        }
        
        if let profile = item as? ResponseAPIContentResolveProfile {
            showProfileWithUserId(profile.userId)
        }
        
    }
    
    func bindScrollView() {
        tableView.rx.willEndDragging
            .subscribe(onNext: { (velocity, targetContentOffset) in
                let currentOffset = self.tableView.contentOffset.y
                let maximumOffset = self.tableView.contentSize.height - self.tableView.frame.size.height
                
                // Change 10.0 to adjust the distance from bottom
                if maximumOffset - currentOffset <= 100 {
                    self.viewModel.fetchNext()
                }
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
