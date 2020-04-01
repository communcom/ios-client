//
//  FeedPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

final class FeedPageVC: PostsViewController {
    override var navigationBarType: BaseViewController.NavigationBarType {.hidden}
    
    // MARK: - Properties
    lazy var floatView = FeedPageFloatView(forAutoLayout: ())
    var floatViewTopConstraint: NSLayoutConstraint!
    var headerView: FeedPageHeaderView!
    var floatViewHeight: CGFloat = 0
    var lastContentOffset: CGFloat = 0
    
    // MARK: - Initializers
    init() {
        let viewModel = FeedPageViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time, userId: Config.currentUser?.id), prefetch: true)
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        
        // tableView
        tableView.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        tableView.keyboardDismissMode = .onDrag
        
        let statusBarView = UIView(backgroundColor: .appMainColor)
        view.addSubview(statusBarView)
        statusBarView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        statusBarView.autoPinEdge(.bottom, to: .top, of: tableView)
        view.addSubview(floatView)
        floatViewTopConstraint = floatView.autoPinEdge(toSuperviewSafeArea: .top)
        floatView.autoPinEdge(toSuperviewSafeArea: .leading)
        floatView.autoPinEdge(toSuperviewSafeArea: .trailing)
        
        statusBarView.autoPinEdge(.bottom, to: .top, of: floatView)
        view.bringSubviewToFront(statusBarView)
        
        headerView = FeedPageHeaderView(tableView: tableView)
        
        headerView.getButton.addTarget(self, action: #selector(promoGetButtonDidTouch), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = floatView.height
        
        if floatViewHeight == 0 {
            tableView.contentInset.top = height
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0.0, bottom: 0.0, right: 0.0)
            floatViewHeight = height
            scrollToTop()
        }
    }
    
    override func bind() {
        super.bind()

        tableView.rx.willBeginDragging.subscribe { _ in
            self.lastContentOffset = self.tableView.contentOffset.y
        }.disposed(by: disposeBag)

        tableView.rx.contentOffset.observeOn(MainScheduler.asyncInstance)
            .subscribe {
            guard let offset = $0.element else { return }

            var needAnimation = false
            var newConstraint: CGFloat = 0.0
            let lastOffset: CGFloat = self.lastContentOffset
            let indent: CGFloat = 100

            if lastOffset > offset.y + indent || offset.y <= 0  {
                needAnimation = self.floatViewTopConstraint.constant <= 0
                newConstraint = 0.0
            } else if lastOffset < offset.y - indent {
                let position = -self.floatView.frame.size.height
                needAnimation = self.floatViewTopConstraint.constant >= position
                newConstraint = position
            }

            if needAnimation {
                self.view.layoutIfNeeded()
                self.floatViewTopConstraint.constant = newConstraint
                UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                })
            }
        }.disposed(by: disposeBag)
        
        // promo
        (viewModel as! FeedPageViewModel).claimedPromos
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (claimedPromos) in
                if !claimedPromos.contains("DANK") {
                    self.headerView.showPromoBanner()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func filterChanged(filter: PostsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        // feedTypeMode
        floatView.setUp(with: filter)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Actions
    @objc func promoGetButtonDidTouch() {
        headerView.getButton.showLoading(cover: true, coverColor: .appMainColor, spinnerColor: .white, size: 20)
        RestAPIManager.instance.getAirdrop(communityId: "DANK")
            .subscribe(onSuccess: { (_) in
                self.headerView.getButton.hideLoading()
                self.headerView.hidePromoBanner()
                UIView.animate(withDuration: 0.3) {
                    self.headerView.layoutIfNeeded()
                }
                self.showDone("done".localized().uppercaseFirst + "!")
            }) { (error) in
                self.headerView.getButton.hideLoading()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
