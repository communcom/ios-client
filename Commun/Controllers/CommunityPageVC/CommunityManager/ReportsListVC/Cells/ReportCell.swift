//
//  ReportCell.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

protocol ReportCellDelegate: class {}

class ReportCell: CommunityManageCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ReportCellDelegate?
    
    override func setUpStackView() {
        super.setUpStackView()
    }
    
    func setUp(with item: ResponseAPIContentGetReport) {
        
    }
    
    override func actionButtonDidTouch() {
        // TODO: - Propose to ban
    }
}
