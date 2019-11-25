//
//  ReportOptionView.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ReportOptionView: MyView {
    lazy var titleLabel = UILabel.with(text: "", textSize: 15, weight: .bold)
    lazy var checkBox = CommunCheckbox(width: 24, height: 24, cornerRadius: 6)
    
    override func commonInit() {
        super.commonInit()
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(checkBox)
        checkBox.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        checkBox.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
}
