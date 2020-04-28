//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommunWalletVC: TransferHistoryVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.normal(translucent: false, backgroundColor: .appMainColorDarkBlack)}
    // MARK: - Properties
    var balancesVM: BalancesViewModel {
        (viewModel as! WalletViewModel).balancesVM
    }
    
    var subscriptionsVM: SubscriptionsViewModel {
        (viewModel as! WalletViewModel).subscriptionsVM
    }

    var isCommunBalance = true

    var balances: [ResponseAPIWalletGetBalance] {
        balancesVM.items.value
    }
    
    var isUserScrolling: Bool {
        tableView.isTracking || tableView.isDragging || tableView.isDecelerating
    }

    var headerTopConstraint: NSLayoutConstraint!
    
    var isShowingUSD = false {
        didSet {
            titleView.setShowUSD(isShowingUSD)
            headerView.isShowingUSD = isShowingUSD
            headerView.reloadData()
        }
    }
    
    // MARK: - Subviews
    lazy var headerView: CommunWalletHeaderView = createHeaderView()
    
    func createHeaderView() -> CommunWalletHeaderView {
        let headerView = CommunWalletHeaderView(forAutoLayout: ())
        headerView.dataSource = self
        return headerView
    }
   
    lazy var tableHeaderView = WalletTableHeaderView(tableView: tableView)
    var myPointsCollectionView: UICollectionView {tableHeaderView.myPointsCollectionView}
    var sendPointsCollectionView: UICollectionView {tableHeaderView.sendPointsCollectionView}
    var headerViewExpandedHeight: CGFloat = 0

    lazy var barTitleLabel = UILabel.with(text: "Equity Value Commun", textSize: 10, weight: .semibold, textColor: .white, textAlignment: .center)
    lazy var barPointLabel = UILabel.with(text: "167 500.23", textSize: 15, weight: .bold, textColor: .white, textAlignment: .center)

    lazy var barBalanceView = createBalanceView()
    lazy var titleView = CMWalletTitleView(forAutoLayout: ())

    func createBalanceView() -> UIView {
        let view = UIView(forAutoLayout: ())
        view.addSubview(barTitleLabel)
        barTitleLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        view.addSubview(barPointLabel)
        barPointLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        barPointLabel.autoPinEdge(.top, to: .bottom, of: barTitleLabel, withOffset: 3)
        
        return view
    }
    
    // MARK: - Initializers
    convenience init() {
        self.init(viewModel: WalletViewModel(symbol: "all"))
    }
    
    // MARK: - Class Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavBarItems()
    }
    
    func setUpNavBarItems() {
        self.setNavBarBackButton(tintColor: .white)
        self.setRightBarButton(imageName: "icon-post-cell-more-center-default", tintColor: .white, action: #selector(optionButtonDidTouch))
    }
    
    // MARK: - Custom Functions
    override func setUp() {
        super.setUp()
        
        headerView.sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        headerView.convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)

        tableHeaderView.sendPointsSeeAllButton.addTarget(self, action: #selector(sendPointsSeeAllDidTouch), for: .touchUpInside)
        tableHeaderView.myPointsSeeAllButton.addTarget(self, action: #selector(myPointsSeeAllDidTouch), for: .touchUpInside)
        tableHeaderView.filterButton.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
        
        tableHeaderView.setMyPointHidden(false)
        
        isShowingUSD = !UserDefaults.standard.bool(forKey: Config.currentEquityValueIsShowingCMN)
        
        titleView.delegate = self
    }
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        
        view.addSubview(headerView)
        headerTopConstraint = headerView.autoPinEdge(toSuperviewEdge: .top)
        headerView.autoPinEdge(toSuperviewEdge: .left)
        headerView.autoPinEdge(toSuperviewEdge: .right)
    }
    
    override func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero)
        view.bringSubviewToFront(headerView)
        
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func bind() {
        super.bind()

        // forward delegate
        myPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        sendPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        headerView.titleLabel.rx.observe(String.self, "text")
        .subscribe(onNext: { text in
            self.barTitleLabel.text = text
        })
        .disposed(by: disposeBag)

        headerView.pointLabel.rx.observe(String.self, "text")
        .subscribe(onNext: { text in
            self.barPointLabel.text = text
        })
        .disposed(by: disposeBag)

        headerView.rx.observe(CGRect.self, "bounds")
        .subscribe(onNext: { bounds in
            guard let height = bounds?.height else {return}
            self.tableView.contentInset.top = height
            self.tableView.contentOffset.y = -height
        })
        .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .map { $0.y }
            .subscribe { (event) in
                var y = event.element ?? 0
                y = y >= -self.headerView.height ? y : -self.headerView.height
                self.headerTopConstraint.constant = -y - self.headerView.height
                let diff = self.headerView.height + y
                self.headerView.updateYPosition(y: diff)
                
                if diff >= 50 {
                    if self.navigationItem.titleView != self.barBalanceView {
                        self.navigationItem.titleView = self.barBalanceView
                    }
                                        
                    let alpha = ((100 / 50) / 100 * diff) - 1
                    self.barBalanceView.alpha = alpha
                } else {
                    let alpha = 1 - ((100 / 50) / 100 * diff)
                    
                    if self.isCommunBalance {
                        self.titleView.alpha = alpha
                        
                        if self.navigationItem.titleView != self.titleView {
                            self.navigationItem.titleView = self.titleView
                        }
                    } else if let carousel = self.headerView.carousel {
                        carousel.alpha = alpha
                        if self.navigationItem.titleView != carousel {
                            self.navigationItem.titleView = carousel
                        }
                    }
                }
        }.disposed(by: disposeBag)
    }
    
    override func bindItems() {
        super.bindItems()
        
        balancesVM.items
            .distinctUntilChanged()
            .subscribe(onNext: { (_) in
                self.reloadData()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(balancesVM.items, (viewModel as! WalletViewModel).hideEmptyPointsRelay)
            .map { (items, shouldHideEmpty) -> [ResponseAPIWalletGetBalance] in
                var items = items
                if shouldHideEmpty {
                    items = items.filter {$0.symbol == "CMN" || $0.balanceValue > 0}
                }
                return items
            }
            .do(onNext: {self.tableHeaderView.setMyPointHidden($0.count == 0)})
            .bind(to: myPointsCollectionView.rx.items(cellIdentifier: "\(MyPointCollectionCell.self)", cellType: MyPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
        
        myPointsCollectionView.rx.modelSelected(ResponseAPIWalletGetBalance.self)
            .subscribe(onNext: { (balance) in
                self.openOtherBalancesWalletVC(withSelectedBalance: balance)
            })
            .disposed(by: disposeBag)
        
        subscriptionsVM.items
            .map({ (items) -> [ResponseAPIContentGetProfile?] in
                let items = items.compactMap {$0.userValue}
                return [nil] + items
            })
            .bind(to: sendPointsCollectionView.rx.items(cellIdentifier: "\(SendPointCollectionCell.self)", cellType: SendPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
    }
    
    override func bindItemSelected() {
        super.bindItemSelected()
        
        sendPointsCollectionView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                guard let user = (self.viewModel as! WalletViewModel).subscriptionsVM.items.value[safe: indexPath.row - 1]?.userValue else {
                    // add friend
                    self.addFriend()
                    return
                }
                self.sendPoint(to: user)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindState() {
        super.bindState()
        (viewModel as! WalletViewModel).balancesVM.state
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self?.headerView.startLoading()
                        self?.myPointsCollectionView.hideLoader()
                        self?.sendPointsCollectionView.hideLoader()
                        self?.myPointsCollectionView.showLoader()
                        self?.sendPointsCollectionView.showLoader()
                    } else {
                        self?.headerView.endLoading()
                        self?.myPointsCollectionView.hideLoader()
                        self?.sendPointsCollectionView.hideLoader()
                    }
                case .listEnded:
                    self?.headerView.endLoading()
                    self?.myPointsCollectionView.hideLoader()
                    self?.sendPointsCollectionView.hideLoader()
                case .listEmpty:
                    self?.headerView.endLoading()
                    self?.myPointsCollectionView.hideLoader()
                    self?.sendPointsCollectionView.hideLoader()
                case .error(let error):
                    self?.headerView.endLoading()
                    self?.myPointsCollectionView.hideLoader()
                    self?.sendPointsCollectionView.hideLoader()
                    self?.view.showErrorView {
                        self?.view.hideErrorView()
                        self?.viewModel.reload()
                    }
                    #if !APPSTRORE
                        self?.showAlert(title: "Error", message: "\(error)")
                    #endif
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func refresh() {
        super.refresh()
        balancesVM.reload()
        subscriptionsVM.reload()
    }
    
    func reloadData() {
        headerView.reloadData()
    }

    // MARK: - Actions
    @objc func optionButtonDidTouch() {
        let vc = CommunWalletOptionsVC()
        vc.hideEmptyPointCompletion = { isOn in
            UserDefaults.standard.set(isOn, forKey: CommunWalletOptionsVC.hideEmptyPointsKey)
            (self.viewModel as! WalletViewModel).hideEmptyPointsRelay.accept(isOn)
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc func convertButtonDidTouch() {
        guard let vc = createConvertVC() else {return}
        show(vc, sender: nil)
    }
    
    func createConvertVC() -> WalletConvertVC? {
        WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value)
    }

    func routeToConvertScene(withTransacion transaction: Transaction) {
        if let history = transaction.history {
            let walletConvertVC = history.symbol == Config.defaultSymbol ?
                WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, historyItem: history) :
                WalletBuyCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, symbol: history.symbol, historyItem: history)

            walletConvertVC.currentSymbol = history.symbol == Config.defaultSymbol ? history.point.symbol! : Config.defaultSymbol
            routeToConvertScene(walletConvertVC: walletConvertVC)
        }
    }

    func routeToConvertScene(walletConvertVC: WalletConvertVC) {
        show(walletConvertVC, sender: nil)
    }

    func createConvertVC(withHistoryItem historyItem: ResponseAPIWalletGetTransferHistoryItem? = nil) -> WalletConvertVC? {
        WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, historyItem: historyItem)
    }

    // Select balance
    @objc func sendButtonDidTouch(_ sender: UIButton) {
        routeToSendPointsScene()
    }

    // Select recipient from friends
    func sendPoint(to user: ResponseAPIContentGetProfile) {
        routeToSendPointsScene(withUser: user)
    }

    private func routeToSendPointsScene(withUser user: ResponseAPIContentGetProfile? = nil) {
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)

        let walletSendPointsVC = WalletSendPointsVC(withSelectedBalanceSymbol: headerView.sendButton.accessibilityHint ?? Config.defaultSymbol, andUser: user)
        show(walletSendPointsVC, sender: nil)
        
        hideHud()
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        
    }
    
    @objc func sendPointsSeeAllDidTouch() {
        guard !subscriptionsVM.items.value.isEmpty else {
            showAlert(title: "no friend found".localized().uppercaseFirst, message: "you don't have any friend. Do you want to".localized().uppercaseFirst, buttonTitles: ["OK".localized(), "Cancel".localized()], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.addFriend()
                }
            }
            return
        }
        
        let vc = SendPointListVC()
        vc.completion = { (user) in
            vc.dismiss(animated: true) {
                self.sendPoint(to: user)
            }
        }
        
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func myPointsSeeAllDidTouch() {
        let vc = MyPointsSeeAllBalancesVC { balance in
            self.openOtherBalancesWalletVC(withSelectedBalance: balance)
        }
        
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
        
    func addFriend() {
        let vc = WalletAddFriendVC()
        vc.completion = { (user) in
            vc.dismiss(animated: true) {
                self.sendPoint(to: user)
            }
        }
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    private func openOtherBalancesWalletVC(withSelectedBalance balance: ResponseAPIWalletGetBalance?) {
        guard   let selectedBalance = balance,
                let balances = (self.viewModel as? WalletViewModel)?.balancesVM.items.value,
                let subscriptions = (self.viewModel as? WalletViewModel)?.subscriptionsVM.items.value,
                var selectedBalanceIndex = balances.firstIndex(where: { $0.symbol == selectedBalance.symbol })
        else { return }
        
        guard headerView.carousel == nil else {
            if selectedBalanceIndex == 0 {
                selectedBalanceIndex = 1
            }
            
            headerView.carousel!.scroll(toItemAtIndex: selectedBalanceIndex - 1, animated: true)
            return
        }
        
        let vc = OtherBalancesWalletVC(balances: balances, symbol: selectedBalance.symbol, subscriptions: subscriptions, history: viewModel.items.value)
        show(vc, sender: nil)
    }
}
