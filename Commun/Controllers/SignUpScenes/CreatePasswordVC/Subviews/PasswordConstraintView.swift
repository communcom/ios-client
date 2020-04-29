//
//  PasswordConstraintView.swift
//  Commun
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class PasswordConstraintView: MyView {
    var constraint: CreatePasswordViewModel.Constraint?
    let activeColor = UIColor.appMainColor
    let inactiveColor = UIColor.appGrayColor
    lazy var symbol = UILabel.with(textSize: 22, weight: .medium, textColor: inactiveColor, textAlignment: .center)
    lazy var title = UILabel.with(textSize: 12, textColor: inactiveColor, textAlignment: .center)
    
    override func commonInit() {
        super.commonInit()
        addSubview(symbol)
        symbol.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        addSubview(title)
        title.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        title.autoPinEdge(.top, to: .bottom, of: symbol, withOffset: 0)
    }
    
    var isActive = false {
        didSet {
            symbol.textColor = isActive ? activeColor : inactiveColor
            title.textColor = isActive ? activeColor : inactiveColor
        }
    }
    
    func setUp(with constraint: CreatePasswordViewModel.Constraint) {
        self.constraint = constraint
        symbol.text = constraint.symbol
        title.text = constraint.title.localized().uppercaseFirst
        isActive = constraint.isSastified
    }
}
