//
//  MyTableHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyTableHeaderView: MyView {
    // MARK: - Properties
    weak var tableView: UITableView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        superview?.layoutIfNeeded()
        tableView?.tableHeaderView = tableView?.tableHeaderView
    }
    
    // MARK: - Initializers
    convenience init(tableView: UITableView) {
        self.init(frame: .zero)
        self.tableView = tableView
        commonInit()
        
        defer {
            let containerView = UIView(forAutoLayout: ())
            
            containerView.addSubview(self)
            self.autoPinEdgesToSuperviewEdges()
            
            tableView.tableHeaderView = containerView
            
            containerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
            containerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
            
            tableView.tableHeaderView?.layoutIfNeeded()
        }
    }
}
