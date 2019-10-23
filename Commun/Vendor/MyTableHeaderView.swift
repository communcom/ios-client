//
//  MyTableHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyTableHeaderView: UIView {
    // MARK: - Properties
    weak var tableView: UITableView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView?.tableHeaderView = tableView?.tableHeaderView
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        
    }
}
