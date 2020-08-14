//
//  ReportCell.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

protocol ReportCellDelegate: class {}

class ReportCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ReportCellDelegate?
    
    func setUp(with item: ResponseAPIContentGetReport) {
    }
}
