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
    // MARK: - Subviews
    lazy var optionsButton = UIButton.option(tintColor: .white, contentInsets: UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 0))
    lazy var headerView = WalletHeaderView(tableView: tableView)
    var sendButton: UIButton {headerView.sendButton}
    var convertButton: UIButton {headerView.convertButton}
    var myPointsCollectionView: UICollectionView {headerView.myPointsCollectionView}
    
    override class func createViewModel() -> TransferHistoryViewModel {
        WalletViewModel()
    }
    
    override func createTableView() -> UITableView {
        let tableView = UITableView(forAutoLayout: ())
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        return tableView
    }
    
    override func setUp() {
        super.setUp()
        title = "wallet".localized().uppercaseFirst
        
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        
        setRightNavBarButton(with: optionsButton)
        optionsButton.addTarget(self, action: #selector(moreActionsButtonDidTouch(_:)), for: .touchUpInside)
        
        sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        bindControls()
        
        // forward delegate
        myPointsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        super.bindItems()
        (viewModel as! WalletViewModel).balancesVM.items
            .subscribe(onNext: { (items) in
                self.headerView.setUp(with: items)
            })
            .disposed(by: disposeBag)
        
        (viewModel as! WalletViewModel).balancesVM.items
            .bind(to: myPointsCollectionView.rx.items(cellIdentifier: "\(MyPointCollectionCell.self)", cellType: MyPointCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
            }
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
                    } else {
                        self?.headerView.endLoading()
                    }
                case .listEnded:
                    self?.headerView.endLoading()
                case .listEmpty:
                    self?.headerView.endLoading()
                case .error(let error):
                    self?.headerView.endLoading()
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
    
    func bindControls() {
        tableView.rx.contentOffset
            .map {$0.y}
            .map {$0 > 16.5 / Config.heightRatio}
            .subscribe(onNext: { showNavBar in
                self.showTitle(showNavBar)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true

        showTitle(tableView.contentOffset.y > 16.5 / Config.heightRatio)
    }
    
    func showTitle(_ show: Bool, animated: Bool = false) {
        showNavigationBar(show, animated: animated) {
            self.optionsButton.tintColor = show ? .black: .white
        }
    }
    
    // MARK: - Actions
    @objc func sendButtonDidTouch() {
        
    }
    
    @objc func convertButtonDidTouch() {
        
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        
    }
}

extension WalletVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: myPointsCollectionView.height)
    }
}
