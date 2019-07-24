//
//  PostPageVC+Header.swift
//  Commun
//
//  Created by Chung Tran on 24/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC: PostHeaderViewDelegate {
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView) {
        self.tableView.tableHeaderView = self.headerView
    }
    
    func createHeaderView() {
        
        guard let view = UINib(nibName: "PostHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as? PostHeaderView else {return}
        
        self.headerView = view
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(headerView)
        
        self.headerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        self.headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        
        
        
        self.headerView.viewDelegate = self
    }
}
