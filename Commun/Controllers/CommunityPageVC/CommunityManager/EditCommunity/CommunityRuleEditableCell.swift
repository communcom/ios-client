//
//  CommunityRuleEditableCell.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunityRuleEditableCell: CommunityRuleCell {
    lazy var editButton = CommunButton.default(height: 30, label: "edit".localized().uppercaseFirst)
    lazy var removeButton = UIButton(height: 30, label: "remove", backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 15)
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .fill, distribution: .fill)
        stackView.addArrangedSubviews([editButton, removeButton])
        return stackView
    }()
    
    override func setUpViews() {
        super.setUpViews()
        stackView.addArrangedSubview(buttonStackView)
    }
    
    override func setUp(with newRule: ResponseAPIContentGetCommunityRule?) {
        super.setUp(with: newRule)
        expandButton.isHidden = false
        buttonStackView.isHidden = !(rule?.isExpanded ?? false)
    }
}
