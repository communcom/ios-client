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
    lazy var floatView = FeedPageHeaderView(forAutoLayout: ())
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
        floatView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        floatView.autoPinEdge(.top, to: .bottom, of: statusBarView)
        view.bringSubviewToFront(statusBarView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = floatView.bounds.height
        if floatViewHeight == 0 {
            tableView.contentInset.top = height
            floatViewHeight = height
            DispatchQueue.main.async {
                self.tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.didScrollToTop
            .subscribe(onNext: { _ in
                self.floatView.topConstraint?.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.willEndDragging
            .map {$0.velocity.y}
            .distinctUntilChanged()
            .subscribe(onNext: { (y) in
                if y == 0 {return}
                self.floatView.topConstraint?.constant = (y < 0) ? 0 : -self.floatViewHeight
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
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
