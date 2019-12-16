//
//  FilterCell.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class FilterCell: MyTableViewCell {
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var checkBox = CommunCheckbox(width: 24, height: 24, cornerRadius: 6)
    lazy var separator = UIView(height: 2, backgroundColor: .f7f7f9)
    
    override var roundedCorner: UIRectCorner {
        didSet {
            if roundedCorner.contains(.bottomLeft) {
                separator.isHidden = true
            } else {
                separator.isHidden = false
            }
            layoutSubviews()
        }
    }
    
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        contentView.addSubview(checkBox)
        checkBox.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        checkBox.autoAlignAxis(toSuperviewAxis: .horizontal)
        checkBox.isUserInteractionEnabled = false
        
        contentView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
}
