//
//  MyTableHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyTableHeaderView: MyView {
    // MARK: - Properties
    weak var tableView: UITableView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reassignTableHeaderView()
    }
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(frame: .zero)
        defer {
            setUpTableHeaderView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTableHeaderView() {
        guard let tableView = tableView else {return}
        let containerView = UIView(forAutoLayout: ())
        
        containerView.addSubview(self)
        self.autoPinEdgesToSuperviewEdges()
        
        tableView.tableHeaderView = containerView
        
        containerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        tableView.tableHeaderView?.layoutIfNeeded()
    }
    
    func reassignTableHeaderView() {
        superview?.layoutIfNeeded()
        tableView?.tableHeaderView = tableView?.tableHeaderView
    }
}
