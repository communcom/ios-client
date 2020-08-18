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
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    var showShadowWhenScrollUp = true
    
    var isInfiniteScrollingEnabled: Bool {true}
    var listLoadingStateObservable: Observable<ListFetcherState> {viewModel.state.asObservable()}
    
    var items: [T] {
        viewModel.items.value
    }
    
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
    
    override func setUp() {
        super.setUp()
        
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
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .none)

        // pull to refresh
        setUpPullToRefresh()
    }
    
    func viewWillSetUpTableView() {
        
    }
    
    func viewDidSetUpTableView() {
        
    }
    
    func setUpPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = UIColor.appGrayColor.inDarkMode(#colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1))
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
        
        if showShadowWhenScrollUp {
            tableView.rx.contentOffset
                .map {$0.y > 3}
                .distinctUntilChanged()
                .subscribe(onNext: { (show) in
                    self.navigationController?.navigationBar.showShadow(show)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func bindItems() {
        viewModel.items
            .map {self.mapItems(items: $0)}
            .do(onNext: { (items) in
                if items.count == 0 && self.viewModel.state.value != .loading(true) {
                    self.handleListEmpty()
                }
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func mapItems(items: [T]) -> [AnimatableSectionModel<String, T>] {
        items.count > 0 ? [ListSection(model: "", items: items)] : []
    }
    
    func bindState() {
        listLoadingStateObservable
            .distinctUntilChanged()
            .do(onNext: { (state) in
                Logger.log(message: "\(state)", event: .debug)
                return
            })
            .subscribe(onNext: {[weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self?.handleLoading()
                        if (self?.viewModel.items.value.count ?? 0) == 0 {
                            self?.refreshControl.endRefreshing()
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
        if isInfiniteScrollingEnabled {
            tableView.addLoadMoreAction { [weak self] in
                self?.viewModel.fetchNext()
            }
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - State handling
    func handleLoading() {
        let notificationsLoadingFooterViewTag = ViewTag.notificationsLoadingFooterView.rawValue
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
        viewModel.reload(clearResult: false)
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> T? {
        viewModel.items.value[safe: indexPath.row]
    }
}
