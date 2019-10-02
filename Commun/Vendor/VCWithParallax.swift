//
//  WithParallax.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

protocol VCWithParallax: UIViewController {
    var tableView: UITableView! {get set}
    var headerView: UIView! {get set}
    var disposeBag: DisposeBag {get}
    var headerHeight: CGFloat {get}
}

extension VCWithParallax {
    func constructParallax() {
        headerView = self.tableView.tableHeaderView!
        self.tableView.tableHeaderView = nil
        self.tableView.addSubview(headerView)
        self.tableView.contentInset = UIEdgeInsets(top: CGFloat(headerHeight), left: CGFloat(0.0), bottom: CGFloat(0.0), right: CGFloat(0.0))
        self.tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        if let rc = tableView.refreshControl {
            self.tableView.bringSubviewToFront(rc)
        }
        
        tableView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: {offsetY in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: CGFloat(0.0), y: -headerHeight, width: UIScreen.main.bounds.width, height: headerHeight)
        if self.tableView.contentOffset.y < -headerHeight {
            let originHeight = headerRect.height
            
            headerRect.origin.y = self.tableView.contentOffset.y
            headerRect.size.height = -self.tableView.contentOffset.y
            
            let scale = headerRect.size.height / originHeight
            self.headerView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            headerView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        headerView.frame = headerRect
        headerView.layoutIfNeeded()
    }
}
