//
//  SubsViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

/// Reusable viewcontroller for subscriptions/subscribers vc
class SubsViewController<T: ListItemType, CellType: ListItemCellType>: ListViewController<T, CellType> {
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    
    override var tableViewMargin: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func setUp() {
        super.setUp()
        navigationItem.hidesBackButton = true
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.backgroundColor = .f3f5fa
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func bind() {
        super.bind()
        tableView.rx.contentOffset
            .map {$0.y > 3}
            .distinctUntilChanged()
            .subscribe(onNext: { (showShadow) in
                if showShadow {
                    self.navigationController?.navigationBar.addShadow(ofColor: .shadow, offset: CGSize(width: 0, height: 2), opacity: 0.1)
                }
                else {
                    self.navigationController?.navigationBar.shadowOpacity = 0
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseNavigationController?.resetNavigationBar()
    }
    
    override func showLoadingFooter() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
}
