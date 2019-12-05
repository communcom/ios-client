//
//  FeedPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

final class FeedPageVC: PostsViewController {
    // MARK: - Properties
    lazy var headerView = FeedPageHeaderView(tableView: tableView)
//    lazy var lastContentOffset: CGFloat = 0.0
    
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
//        view.addSubview(floatView)
//        floatView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
//        floatView.autoPinEdge(.top, to: .bottom, of: statusBarView)
        
        view.bringSubviewToFront(statusBarView)
    }
    
    override func bind() {
        super.bind()
        
//        tableView.rx.willBeginDragging.subscribe({ _ in
//            self.lastContentOffset = self.tableView.contentOffset.y
//        }).disposed(by: disposeBag)
//
//        // show/hide navigation view
//        tableView.rx.contentOffset.subscribe {
//            guard let offset = $0.element else { return }
//
//            var needAnimation = false
//            var newConstraint: CGFloat = 0.0
//            var inset: CGFloat = 0.0
//            let lastOffset: CGFloat = self.lastContentOffset
//            if lastOffset > offset.y || offset.y <= 0  {
//                needAnimation = self.floatView.topConstraint!.constant <= 0
//                newConstraint = 0.0
//                inset = self.floatView.frame.size.height
//            } else if lastOffset < offset.y {
//                let position = -self.floatView.frame.size.height
//                needAnimation = self.floatView.topConstraint!.constant >= position
//                newConstraint = position
//                inset = 0.0
//            }
//
//            if needAnimation {
//                self.view.layoutIfNeeded()
//                self.floatView.topConstraint!.constant = newConstraint
//                self.tableView.contentInset.top = inset
//                UIView.animate(withDuration: 0.3, animations: { [unowned self] in
//                    self.tableView.scrollIndicatorInsets.top = self.tableView.contentInset.top
//                    self.view.layoutIfNeeded()
//                })
//            }
//
//        }.disposed(by: disposeBag)
    }
    
    override func filterChanged(filter: PostsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        // feedTypeMode
        headerView.setUp(with: filter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
