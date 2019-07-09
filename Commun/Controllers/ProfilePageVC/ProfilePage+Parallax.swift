//
//  ProfilePage+Parallax.swift
//  Commun
//
//  Created by Chung Tran on 25/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ProfilePageVC {
    func constructParallax() {
        headerView = self.tableView.tableHeaderView!
        self.tableView.tableHeaderView = nil
        self.tableView.addSubview(headerView)
        let height = 598
        self.tableView.contentInset = UIEdgeInsets(top: CGFloat(height), left: CGFloat(0.0), bottom: CGFloat(0.0), right: CGFloat(0.0))
        self.tableView.contentOffset = CGPoint(x: 0, y: -height)
        self.tableView.bringSubviewToFront(self.tableView.refreshControl!)
        
        tableView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: {offsetY in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
    }
    
    func updateHeaderView() {
        let height = CGFloat(598)
        var headerRect = CGRect(x: CGFloat(0.0), y: -height, width: UIScreen.main.bounds.width, height: height)
        if self.tableView.contentOffset.y < -height {
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
