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
    
    var balances: [ResponseAPIWalletGetBalance] {
        balancesSubject.value
    }
    
    var isUserScrolling: Bool {
        tableView.isTracking || tableView.isDragging || tableView.isDecelerating
    }

    var tableTopConstraint: NSLayoutConstraint!
    
    // MARK: - Subviews
    lazy var headerView: CommunWalletHeaderView = createHeaderView()
    func createHeaderView() -> CommunWalletHeaderView {
        let headerView = CommunWalletHeaderView(forAutoLayout: ())
        headerView.delegate = self
        headerView.dataSource = self
        return headerView
    }
    lazy var tableHeaderView = WalletTableHeaderView(tableView: tableView)
    var myPointsCollectionView: UICollectionView {tableHeaderView.myPointsCollectionView}
    var sendPointsCollectionView: UICollectionView {tableHeaderView.sendPointsCollectionView}
    var headerViewExpandedHeight: CGFloat = 0

    private var barStyle: UIStatusBarStyle = .lightContent

    // MARK: - Initializers
    convenience init() {
        self.init(viewModel: WalletViewModel())
    }
    
    override func createTableView() -> UITableView {
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.top = 0

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        tableTopConstraint = tableView.autoPinEdge(toSuperviewEdge: .top)
        view.bringSubviewToFront(headerView)
        return tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func setUp() {
        super.setUp()
        headerView.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        headerView.sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        headerView.convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        
        tableHeaderView.sendPointsSeeAllButton.addTarget(self, action: #selector(sendPointsSeeAllDidTouch), for: .touchUpInside)
        tableHeaderView.myPointsSeeAllButton.addTarget(self, action: #selector(myPointsSeeAllDidTouch), for: .touchUpInside)
        
        tableHeaderView.filterButton.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
        
        tableHeaderView.setMyPointHidden(false)
    }
    
    override func bind() {
        super.bind()
        
        // forward delegate
        myPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        sendPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .map {$0.y}
            .filter {_ in self.isUserScrolling}
            .map({ y -> Bool in
                return y > 0
            })
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (collapse) in
                self.headerView.setIsCollapsed(collapse)
                self.changeStatusBarStyle(collapse ? .default : .lightContent)
            })
            .disposed(by: disposeBag)
        
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }

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
//                if indexPath.row == 0 { // Temp hide Add friends
//                    self.addFriend()
//                } else {
                    guard let user = (self.viewModel as! WalletViewModel).subscriptionsVM.items.value[safe: indexPath.row - 1]?.userValue else {return}
                    self.sendPoint(to: user)
//                }
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
        vc.completion = {
            self.viewModel.reload()
        }
        let nc = navigationController as? BaseNavigationController
        nc?.shouldResetNavigationBarOnPush = false
        show(vc, sender: nil)
        nc?.shouldResetNavigationBarOnPush = true
    }
    
    // Select balance
    @objc func sendButtonDidTouch(_ sender: UIButton) {
        routeToSendPointsScene()
    }

    // Select recipient from friends
    func sendPoint(to user: ResponseAPIContentGetSubscriptionsUser) {
        routeToSendPointsScene(withRecipient: user)
    }

    private func routeToSendPointsScene(withRecipient recipient: ResponseAPIContentGetSubscriptionsUser? = nil) {
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)

        let walletSendPointsVC = WalletSendPointsVC(withSelectedBalance: headerView.sendButton.accessibilityHint ?? Config.defaultSymbol, andFriend: recipient)
        show(walletSendPointsVC, sender: nil)

        hideHud()
    }
    
    func createConvertVC() -> WalletConvertVC? {
        WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value)
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
        guard let balance = balance, let index = (balances.filter {$0.symbol != Config.defaultSymbol}).firstIndex(where: {$0.symbol == balance.symbol}) else {return}
        let vc = OtherBalancesWalletVC(balances: viewModel.balancesVM.items.value, selectedIndex: index, subscriptions: viewModel.subscriptionsVM.items.value, history: viewModel.items.value)
        show(vc, sender: self)
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

extension CommunWalletVC: CommunWalletHeaderViewDelegate, CommunWalletHeaderViewDatasource {
    func data(forWalletHeaderView headerView: CommunWalletHeaderView) -> [ResponseAPIWalletGetBalance]? {
        balances
    }
    
    func walletHeaderView(_ headerView: CommunWalletHeaderView, willUpdateHeightCollapsed isCollapsed: Bool) {
//        if isCollapsed {
//            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            headerViewExpandedHeight = height
//            tableView.bounds.origin.y = headerViewExpandedHeight
//        } else {
            resetTableViewContentInset()
//        }
    }
    
    private func resetTableViewContentInset() {
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        if headerViewExpandedHeight == height {return}
        headerViewExpandedHeight = height

        view.layoutIfNeeded()
        tableTopConstraint.constant = headerViewExpandedHeight - 30
        tableView.contentInset.top = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
