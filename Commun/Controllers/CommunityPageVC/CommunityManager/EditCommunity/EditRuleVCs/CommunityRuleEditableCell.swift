//
//  CommunityRuleEditableCell.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol CommunityRuleEditableCellDelegate: class {
    func communityRuleEditableCellButtonRemoveDidTouch(_ cell: CommunityRuleEditableCell)
    func communityRuleEditableCellButtonEditDidTouch(_ cell: CommunityRuleEditableCell)
}

class CommunityRuleEditableCell: CommunityRuleCell {
    weak var delegate: CommunityRuleEditableCellDelegate?
    
    lazy var editButton: CommunButton = {
        let button = CommunButton.default(height: 30, label: "edit".localized().uppercaseFirst)
        button.addTarget(self, action: #selector(buttonEditDidTouch), for: .touchUpInside)
        return button
    }()
    lazy var removeButton: UIButton = {
        let button = UIButton(height: 30, label: "remove".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 15, contentInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
        
        button.addTarget(self, action: #selector(buttonRemoveDidTouch), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .fill, distribution: .fill)
        
        stackView.addArrangedSubviews([editButton, removeButton, .spacer(height: 30)])
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
    
    @objc func buttonRemoveDidTouch() {
        delegate?.communityRuleEditableCellButtonRemoveDidTouch(self)
    }
    
    @objc func buttonEditDidTouch() {
        delegate?.communityRuleEditableCellButtonEditDidTouch(self)
    }
}
