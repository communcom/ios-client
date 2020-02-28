//
//  ListViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    var pullToRefreshAdded = false
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    
    // search
    var isSearchEnabled: Bool {false}
    lazy var searchController = UISearchController.default()
    
    // MARK: - Subviews
    lazy var tableView = UITableView(forAutoLayout: ())
    
    // MARK: - Initializers
    init(viewModel: ListViewModel<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isSearchEnabled {
            searchController.roundCorner()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // search
        if isSearchEnabled {
            setUpSearchController()
        }
        
        // before setting tableView
        viewWillSetUpTableView()
        
        // setUpTableView
        setUpTableView()
        
        // after setting tableView
        viewDidSetUpTableView()
        
        // registerCell
        registerCell()
        
        // set up datasource
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { _, _, indexPath, item in
                let cell = self.configureCell(with: item, indexPath: indexPath)
                return cell
            }
        )
        
        dataSource.animationConfiguration = AnimationConfiguration(reloadAnimation: .none)

        // pull to refresh
        if !pullToRefreshAdded {
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
            tableView.addSubview(refreshControl)
            refreshControl.tintColor = .appGrayColor
            pullToRefreshAdded = true
        }
    }
    
    func viewWillSetUpTableView() {
        
    }
    
    func viewDidSetUpTableView() {
        
    }
    
    func setUpTableView() {
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: tableViewMargin)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func registerCell() {
        tableView.register(CellType.self, forCellReuseIdentifier: String(describing: CellType.self))
    }
    
    func configureCell(with item: T, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: CellType.self)) as! CellType
        cell.setUp(with: item as! CellType.T)
        cell.delegate = self as? CellType.Delegate
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
            bindSearchBar()
        }
    }
    
    func bindItems() {
        if !isSearchEnabled {
            viewModel.items
                .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        } else {
            bindItemsWithSearchResult()
        }
        
    }
    
    func bindItemsWithSearchResult() {
        Observable.merge(viewModel.items.asObservable(), viewModel.searchResult.filter {$0 != nil}.map {$0!}.asObservable())
            .map {[ListSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.searchResult
            .filter {$0 == nil}
            .subscribe(onNext: { (_) in
                self.viewModel.items.accept(self.viewModel.items.value)
            })
            .disposed(by: disposeBag)
    }
    
    func bindState() {
        viewModel.state
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .do(onNext: { (state) in
                Logger.log(message: "\(state)", event: .debug)
                return
            })
            .subscribe(onNext: {[weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        if (self?.viewModel.items.value.count ?? 0) == 0 {
                            self?.refreshControl.endRefreshing()
                            self?.handleLoading()
                        }
                    } else {
                        self?.refreshControl.endRefreshing()
                    }
                case .listEnded:
                    self?.handleListEnded()
                    self?.refreshControl.endRefreshing()
                case .listEmpty:
                    self?.handleListEmpty()
                    self?.refreshControl.endRefreshing()
                case .error(let error):
                    self?.refreshControl.endRefreshing()
                    self?.handleListError()
                    #if !APPSTORE
                        self?.showAlert(title: "Error", message: "\(error)")
                    #endif
                }
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
        
        if let profile = item as? ResponseAPIContentGetProfile {
            showProfileWithUserId(profile.userId)
            return
        }
        
    }
    
    func bindScrollView() {
        tableView.addLoadMoreAction { [weak self] in
            self?.viewModel.fetchNext()
        }
            .disposed(by: disposeBag)
    }
    
    // MARK: - State handling
    func handleLoading() {
        tableView.addLoadingFooterView(
            rowType: PlaceholderNotificationCell.self,
            tag: notificationsLoadingFooterViewTag,
            rowHeight: 88,
            numberOfRows: 1
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
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst,
                                                description: description.localized().uppercaseFirst,
                                                buttonLabel: "retry".localized().uppercaseFirst) {
            self.viewModel.fetchNext(forceRetry: true)
        }
    }
    
    @objc func refresh() {
        refreshControl.endRefreshing()
        viewModel.reload(clearResult: false)
    }
    
    // MARK: - Search manager
    func bindSearchBar() {
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                self.search(query)
            })
            .disposed(by: disposeBag)

    }
    private func setUpSearchController() {
        self.definesPresentationContext = true
        layoutSearchBar()
    }

    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
    }
    
    func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            if viewModel.fetcher.search != nil {
                viewModel.fetcher.search = nil
                handleEmptyKeyword()
            }
            return
        }
        
        if viewModel.fetcher.search != keyword {
            viewModel.fetcher.search = keyword
            viewModel.reload(clearResult: false)
        }
    }
    
    func handleEmptyKeyword() {
        viewModel.reload()
    }
}
