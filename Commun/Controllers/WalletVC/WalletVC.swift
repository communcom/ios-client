//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CircularCarousel

class WalletVC: TransferHistoryVC {
    // MARK: - Properties
    var maxItemsInCarousel = 5
    var carouselHeight: CGFloat = 40
    var currentBalance: ResponseAPIWalletGetBalance? {
        (self.viewModel as! WalletViewModel).balancesVM.items.value[safe: headerView.currentIndex]
    }
    
    // MARK: - Subviews
    lazy var carousel = CircularCarousel(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
    lazy var optionsButton = UIButton.option(tintColor: .white, contentInsets: UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 0))
    lazy var headerView = WalletHeaderView(tableView: tableView)
    var sendButton: UIButton {headerView.sendButton}
    var convertButton: UIButton {headerView.convertButton}
    var myPointsCollectionView: UICollectionView {headerView.myPointsCollectionView}
    var sendPointsCollectionView: UICollectionView {headerView.sendPointsCollectionView}
    
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
        navigationItem.titleView = carousel
        carousel.delegate = self
        carousel.dataSource = self
        
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
        
        sendPointsCollectionView.rx.setDelegate(self)
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
                self.carousel.reloadData()
            }
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Actions
    @objc func sendButtonDidTouch() {
        
    }
    
    @objc func convertButtonDidTouch() {
        
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        
    }
    
    @objc func trade() {
        guard let balance = currentBalance else {return}
        let vc: UIViewController
        if balance.symbol == "CMN" {
            vc = WalletSellCommunVC()
        } else {
            vc = WalletBuyCommunVC(symbol: balance.symbol)
        }
        show(vc, sender: nil)
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

extension WalletVC: CircularCarouselDataSource, CircularCarouselDelegate {
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return headerView.currentIndex
    }
    
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return min(maxItemsInCarousel, (viewModel as! WalletViewModel).balancesVM.items.value.count)
    }
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView: UIView?) -> UIView {
        let balances = (viewModel as! WalletViewModel).balancesVM.items.value
        guard
            let balance = balances[safe: indexPath.row]
            else {
                return UIView()
        }
        
        var view = reuseView

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: carouselHeight, height: carouselHeight))
            let imageView = MyAvatarImageView(size: carouselHeight)
            imageView.borderColor = .white
            imageView.borderWidth = 2
            imageView.tag = 1
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
        
        if balance.symbol == "CMN" {
            imageView.image = UIImage(named: "tux")
        } else {
            imageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? "B\(indexPath.row)")
        }
        
        return view!
    }
    // MARK: CircularCarouselDelegate
    func carousel<CGFloat>(_ carousel: CircularCarousel, valueForOption option: CircularCarouselOption, withDefaultValue defaultValue: CGFloat) -> CGFloat {
        if option == .itemWidth {
            return CoreGraphics.CGFloat(carouselHeight) as! CGFloat
        }
        
        if option == .spacing {
            return CoreGraphics.CGFloat(8) as! CGFloat
        }
        
        if option == .minScale {
            return CoreGraphics.CGFloat(0.7) as! CGFloat
        }
        
        return defaultValue
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        headerView.currentIndex = index
    }
}
