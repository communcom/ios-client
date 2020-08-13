//
//  ProposalCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol ProposalCellDelegate: class {}

class ProposalPostCell: CMPostCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ProposalCellDelegate?
    
    override func setUpViews() {
        super.setUpViews()
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
    }
}
