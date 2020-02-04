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
    // MARK: - Properties
    var balancesSubject: BehaviorRelay<[ResponseAPIWalletGetBalance]> {
        (viewModel as! WalletViewModel).balancesVM.items
    }

    var isCommunBalance = true

    var balances: [ResponseAPIWalletGetBalance] {
        balancesSubject.value
    }
    
    var isUserScrolling: Bool {
        tableView.isTracking || tableView.isDragging || tableView.isDecelerating
    }

    var headerTopConstraint: NSLayoutConstraint!
    
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

    private var barStyle: UIStatusBarStyle = .lightContent

    var balanceView: UIView {
        let view = UIView(forAutoLayout: ())

        return view
    }

    lazy var barTitleLabel = UILabel.with(text: "Equity Value Commun", textSize: 10, weight: .semibold, textColor: .white, textAlignment: .center)
    lazy var barPointLabel = UILabel.with(text: "167 500.23", textSize: 15, weight: .bold, textColor: .white, textAlignment: .center)

    lazy var barBalanceView = createBalanceView()
    lazy var logoView = UIView.transparentCommunLogo(size: 40)

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
        self.init(viewModel: WalletViewModel(symbol: "CMN"))
    }

    override func viewWillAppear(_ animated: Bool) {
        setNavBarBackButton(tintColor: .white)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .appMainColor
        self.navigationController?.navigationBar.tintColor = .white
        self.setTabBarHidden(false)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.title = ""
        
        super.viewWillDisappear(animated)
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
    }
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        view.addSubview(headerView)
        headerTopConstraint = headerView.autoPinEdge(toSuperviewEdge: .top)
        headerView.autoPinEdge(toSuperviewEdge: .left)
        headerView.autoPinEdge(toSuperviewEdge: .right)
//        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
    }
    
    override func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.showsVerticalScrollIndicator = false

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
            .map {$0.y}
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
                        self.logoView.alpha = alpha
                        if self.navigationItem.titleView != self.logoView {
                            self.navigationItem.titleView = self.logoView
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
        balancesSubject
            .distinctUntilChanged()
            .subscribe(onNext: { (_) in
                self.reloadData()
            })
            .disposed(by: disposeBag)
        
        balancesSubject
            .bind(to: myPointsCollectionView.rx.items(cellIdentifier: "\(MyPointCollectionCell.self)", cellType: MyPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
        
        myPointsCollectionView.rx.modelSelected(ResponseAPIWalletGetBalance.self)
            .subscribe(onNext: { (balance) in
                self.openOtherBalancesWalletVC(withSelectedBalance: balance)
            })
            .disposed(by: disposeBag)
        
        (viewModel as! WalletViewModel).subscriptionsVM.items
            .map({ (items) -> [ResponseAPIContentGetSubscriptionsUser?] in
                let items = items.compactMap {$0.userValue}
                return items//[nil] + items // Temp hide Add friends
            })
            .bind(to: sendPointsCollectionView.rx.items(cellIdentifier: "\(SendPointCollectionCell.self)", cellType: SendPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
    }
    
    func reloadData() {
        headerView.reloadData()
    }
    
    override func bindItemSelected() {
        super.bindItemSelected()
        
        sendPointsCollectionView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                guard let user = (self.viewModel as! WalletViewModel).subscriptionsVM.items.value[safe: indexPath.row]?.userValue else {return}
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

    // MARK: - Actions
    @objc func convertButtonDidTouch() {
        guard let vc = createConvertVC() else {return}
        let nc = navigationController as? BaseNavigationController
        nc?.shouldResetNavigationBarOnPush = false
        show(vc, sender: nil)
        nc?.shouldResetNavigationBarOnPush = true
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
        let nc = navigationController as? BaseNavigationController
        nc?.shouldResetNavigationBarOnPush = false
        show(walletConvertVC, sender: nil)
        nc?.shouldResetNavigationBarOnPush = true
    }

    func createConvertVC(withHistoryItem historyItem: ResponseAPIWalletGetTransferHistoryItem? = nil) -> WalletConvertVC? {
        WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, historyItem: historyItem)
    }

    // Select balance
    @objc func sendButtonDidTouch(_ sender: UIButton) {
        routeToSendPointsScene()
    }

    // Select recipient from friends
    func sendPoint(to user: ResponseAPIContentGetSubscriptionsUser) {
        routeToSendPointsScene(withUser: user)
    }

    private func routeToSendPointsScene(withUser user: ResponseAPIContentGetSubscriptionsUser? = nil) {
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)

        if let baseNC = navigationController as? BaseNavigationController {
            let walletSendPointsVC = WalletSendPointsVC(withSelectedBalanceSymbol: headerView.sendButton.accessibilityHint ?? Config.defaultSymbol, andUser: user)
            baseNC.shouldResetNavigationBarOnPush = false
            show(walletSendPointsVC, sender: nil)
        }
        
        hideHud()
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        
    }
    
    @objc func sendPointsSeeAllDidTouch() {
        let vc = SendPointListVC { (user) in
            self.sendPoint(to: user)
        }
        
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func myPointsSeeAllDidTouch() {
        let vc = BalancesVC { balance in
            self.openOtherBalancesWalletVC(withSelectedBalance: balance)
        }
        
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
        
    func addFriend() {
        showAlert(title: "TODO: Add friend", message: "add friend")
    }
    
    private func openOtherBalancesWalletVC(withSelectedBalance balance: ResponseAPIWalletGetBalance?) {
        let viewModel = (self.viewModel as! WalletViewModel)
        guard let balance = balance else {return}
        let vc = OtherBalancesWalletVC(balances: viewModel.balancesVM.items.value, symbol: balance.symbol, subscriptions: viewModel.subscriptionsVM.items.value, history: viewModel.items.value)
        let nc = navigationController as? BaseNavigationController
        nc?.shouldResetNavigationBarOnPush = false
        show(vc, sender: nil)
        nc?.shouldResetNavigationBarOnPush = true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CommunWalletVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sendPointsCollectionView {
            return CGSize(width: 90, height: SendPointCollectionCell.height)
        }
        return CGSize(width: 140, height: MyPointCollectionCell.height)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.barStyle
    }

    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.barStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension CommunWalletVC: CommunWalletHeaderViewDatasource {
    func data(forWalletHeaderView headerView: CommunWalletHeaderView) -> [ResponseAPIWalletGetBalance]? {
        balances
    }
}
