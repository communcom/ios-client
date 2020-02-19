//
//  FilterCell.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class FilterCell: MyTableViewCell {
    // MARK: - Properties
    lazy var titleLabel = UILabel.with(textSize: CGFloat.adaptive(width: 15.0), weight: .semibold)
    lazy var checkBox = CommunCheckbox(width: CGFloat.adaptive(width: 24.0), height: CGFloat.adaptive(width: 24.0), cornerRadius: CGFloat.adaptive(width: 6.0))
    lazy var separator = UIView(height: CGFloat.adaptive(height: 2.0), backgroundColor: .f7f7f9)
    
    // MARK: - Custom Functions
    override var roundedCorner: UIRectCorner {
        didSet {
            separator.isHidden = roundedCorner.contains(.bottomLeft)
            layoutSubviews()
        }
    }
        
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(width: 15.0))
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        contentView.addSubview(checkBox)
        checkBox.autoPinEdge(toSuperviewEdge: .trailing, withInset: CGFloat.adaptive(width: 15.0))
        checkBox.autoAlignAxis(toSuperviewAxis: .horizontal)
        checkBox.isUserInteractionEnabled = false
        checkBox.notShowOffCheckbox = true
        
        contentView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
}
