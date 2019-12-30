//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class WalletVC: TransferHistoryVC {
    // MARK: - Properties
    var currentBalance: ResponseAPIWalletGetBalance? {
        (self.viewModel as! WalletViewModel).balancesVM.items.value[safe: headerView.currentIndex.value]
    }
    
    // MARK: - Subviews
    lazy var headerView = WalletHeaderView(forAutoLayout: ())
    lazy var tableHeaderView = WalletTableHeaderView(tableView: tableView)
    var myPointsCollectionView: UICollectionView {tableHeaderView.myPointsCollectionView}
    var sendPointsCollectionView: UICollectionView {tableHeaderView.sendPointsCollectionView}
    
    override class func createViewModel() -> TransferHistoryViewModel {
        WalletViewModel()
    }
    
    override func createTableView() -> UITableView {
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let tableView = UITableView(forAutoLayout: ())
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: headerView)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.contentView.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 30 * Config.heightRatio)
        headerView.shadowView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 19, offset: CGSize(width: 0, height: 14), opacity: 0.3)
    }
    
    override func setUp() {
        super.setUp()
        headerView.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        headerView.sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        headerView.convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        
        tableHeaderView.sendPointsSeeAllButton.addTarget(self, action: #selector(sendPointsSeeAllDidTouch), for: .touchUpInside)
        tableHeaderView.myPointsSeeAllButton.addTarget(self, action: #selector(myPointsSeeAllDidTouch), for: .touchUpInside)
        
        tableHeaderView.filterButton.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        
        // headerView
        headerView.currentIndex
            .map {$0 != 0}
            .subscribe(onNext: { (shouldHide) in
                self.tableHeaderView.setMyPointHidden(shouldHide)
            })
            .disposed(by: disposeBag)
        
        // forward delegate
        myPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        sendPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        super.bindItems()
        (viewModel as! WalletViewModel).balancesVM.items
            .subscribe(onNext: { (items) in
                self.headerView.setUp(with: items)
                self.tableHeaderView.setMyPointHidden(self.headerView.currentIndex.value != 0)
            })
            .disposed(by: disposeBag)
        
        (viewModel as! WalletViewModel).balancesVM.items
            .bind(to: myPointsCollectionView.rx.items(cellIdentifier: "\(MyPointCollectionCell.self)", cellType: MyPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
        
        myPointsCollectionView.rx.modelSelected(ResponseAPIWalletGetBalance.self)
            .subscribe(onNext: { (balance) in
                self.headerView.switchToSymbol(balance.symbol)
            })
            .disposed(by: disposeBag)
        
        (viewModel as! WalletViewModel).subscriptionsVM.items
            .map({ (items) -> [ResponseAPIContentGetSubscriptionsUser?] in
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
                if indexPath.row == 0 {
                    self.addFriend()
                } else {
                    guard let user = (self.viewModel as! WalletViewModel).subscriptionsVM.items.value[safe: indexPath.row - 1]?.userValue else {return}
                    self.sendPoint(to: user)
                }
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Actions
    @objc func sendButtonDidTouch() {
        
    }
    
    @objc func convertButtonDidTouch() {
        guard let balance = currentBalance else {return}
        let vc: WalletConvertVC
        if balance.symbol == "CMN" {
            vc = WalletSellCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value)
        } else {
            vc = WalletBuyCommunVC(balances: (self.viewModel as! WalletViewModel).balancesVM.items.value, symbol: balance.symbol)
        }
        vc.completion = {
            self.viewModel.reload()
        }
        let nc = navigationController as? BaseNavigationController
        nc?.shouldResetNavigationBarOnPush = false
        show(vc, sender: nil)
        nc?.shouldResetNavigationBarOnPush = true
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
            self.headerView.switchToSymbol(balance.symbol)
        }
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    func sendPoint(to user: ResponseAPIContentGetSubscriptionsUser) {
        showAlert(title: "TODO: Send point", message: user.userId)
    }
    
    func addFriend() {
        showAlert(title: "TODO: Add friend", message: "add friend")
    }
}

extension WalletVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sendPointsCollectionView {
            return CGSize(width: 90, height: SendPointCollectionCell.height)
        }
        return CGSize(width: 140, height: MyPointCollectionCell.height)
    }
}
