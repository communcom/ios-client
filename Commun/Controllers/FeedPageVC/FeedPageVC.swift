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
    // MARK: - Properties
    lazy var floatView = FeedPageFloatView(forAutoLayout: ())
    var floatViewTopConstraint: NSLayoutConstraint!
    var headerView: FeedPageHeaderView!
    var floatViewHeight: CGFloat = 0
    var lastContentOffset: CGFloat = 0

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
