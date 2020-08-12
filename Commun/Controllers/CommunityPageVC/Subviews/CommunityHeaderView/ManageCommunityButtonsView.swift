//
//  ManageCommunityButtonsStackView.swift
//  Commun
//
//  Created by Chung Tran on 8/12/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ManageCommunityButtonsView: MyView {
    // MARK: - Subviews
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 0, alignment: .fill, distribution: .fill)
        
        let spacer = UIView(forAutoLayout: ())
        stackView.addArrangedSubview(spacer)
        
        return stackView
    }()
    
    lazy var reportsButton = createButton(title: "reports".localized().uppercaseFirst, countLabel: reportsCountLabel)
    lazy var reportsCountLabel = UILabel.with(textSize: 14, weight: .medium)
    
    lazy var proposalsButton = createButton(title: "proposals".localized().uppercaseFirst, countLabel: proposalsCountLabel)
    lazy var proposalsCountLabel = UILabel.with(textSize: 14, weight: .medium)
    
    lazy var manageCommunityButton = UIImageView(width: 44, height: 44, cornerRadius: 10, imageNamed: "settings-square-blue")
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.addArrangedSubviews([reportsButton, proposalsButton, manageCommunityButton])
        stackView.setCustomSpacing(10, after: reportsButton)
        stackView.setCustomSpacing(16, after: proposalsButton)
    }
    
    private func createButton(title: String, countLabel: UILabel) -> UIView {
        let view = UIView(height: 44, backgroundColor: .appLightGrayColor, cornerRadius: 10)
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        stackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        let label = UILabel.with(text: title, textSize: 14, weight: .semibold, textColor: .appMainColor)
        stackView.addArrangedSubviews([label, countLabel])
        return view
    }
}
