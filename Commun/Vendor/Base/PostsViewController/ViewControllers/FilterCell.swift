//
//  FilterCell.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FilterCell: MyTableViewCell {
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var checkBox = CommunCheckbox(width: 24, height: 24, cornerRadius: 6)
    
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        contentView.addSubview(checkBox)
        checkBox.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        checkBox.autoAlignAxis(toSuperviewAxis: .horizontal)
        checkBox.isUserInteractionEnabled = false
    }
}
