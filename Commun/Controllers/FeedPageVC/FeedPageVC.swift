//
//  FeedPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

final class FeedPageVC: PostsViewController {
    // MARK: - Properties
    lazy var floatView = FeedPageFloatView(forAutoLayout: ())
    var floatViewTopConstraint: NSLayoutConstraint!
    var headerView: FeedPageHeaderView!
    var floatViewHeight: CGFloat = 0
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = floatView.height
        if floatViewHeight == 0 {
            tableView.contentInset.top = height
            floatViewHeight = height
            scrollToTop()
        }
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.didScrollToTop
            .subscribe(onNext: { _ in
                self.floatViewTopConstraint.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.floatViewTopConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    self.floatView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.willEndDragging
            .map {$0.velocity.y}
            .distinctUntilChanged()
            .subscribe(onNext: { y in
                self.updateFloatViewVisible(y)
            })
            .disposed(by: disposeBag)

        tableView.rx.didEndScrollingAnimation.subscribe { _ in
            self.updateFloatViewVisible(self.tableView.contentOffset.y, animation: false)
        }.disposed(by: disposeBag)
    }

    private func updateFloatViewVisible(_ y: CGFloat, animation: Bool = true) {
        if y == 0 { return }
        self.floatViewTopConstraint.constant = (y < 0) ? 0 : -self.floatViewHeight
        UIView.animate(withDuration: animation ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func filterChanged(filter: PostsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        // feedTypeMode
        floatView.setUp(with: filter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
