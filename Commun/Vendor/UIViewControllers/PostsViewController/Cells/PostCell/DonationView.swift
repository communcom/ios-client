//
//  DonationView.swift
//  Commun
//
//  Created by Chung Tran on 4/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DonationView: CMMessageView {
    // MARK: - Properties
    lazy var amounts = [10, 100, 1000]
    
    // MARK: - Subviews
    lazy var leadingLabel = UILabel.with(numberOfLines: 2)
    lazy var buttonStackView = UIStackView(axis: .horizontal, spacing: 5, alignment: .fill, distribution: .fill)
    lazy var amountButtons: [UIButton] = amounts.map {UIButton(width: 60, label: "+\($0)", labelFont: .systemFont(ofSize: 12), backgroundColor: UIColor.white.withAlphaComponent(0.1), textColor: .white, cornerRadius: 17)}
    lazy var otherButton = UIButton(width: 60, label: "other".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12), backgroundColor: UIColor.white.withAlphaComponent(0.1), textColor: .white, cornerRadius: 17)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        contentView.addSubview(leadingLabel)
        leadingLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        leadingLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        leadingLabel.attributedText = NSMutableAttributedString()
            .text("donate".localized().uppercaseFirst + ":", size: 12, weight: .semibold, color: .white)
            .text("\n")
            .text("points".localized().uppercaseFirst, size: 10, weight: .medium, color: UIColor.white.withAlphaComponent(0.3))
        
        contentView.addSubview(buttonStackView)
        buttonStackView.autoPinEdge(.leading, to: .trailing, of: leadingLabel, withOffset: 8)
        buttonStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        buttonStackView.autoPinEdge(.trailing, to: .leading, of: closeButton)
        
        buttonStackView.addArrangedSubviews(amountButtons + [otherButton])
    }
}
