//
//  SubsViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

/// Reusable viewcontroller for subscriptions/subscribers vc
class SubsViewController<T: ListItemType, CellType: ListItemCellType>: ListViewController<T, CellType> {
    var showShadowWhenScrollUp = true
    lazy var closeButton = UIButton.close()
    
    override var tableViewMargin: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func setUp() {
        super.setUp()
        navigationItem.hidesBackButton = true
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.backgroundColor = .appLightGrayColor
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func bind() {
        super.bind()
        if showShadowWhenScrollUp {
            tableView.rx.contentOffset
                .map {$0.y > 3}
                .distinctUntilChanged()
                .subscribe(onNext: { (show) in
                    self.navigationController?.navigationBar.showShadow(show)
                })
                .disposed(by: disposeBag)
        }
    }

    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}
