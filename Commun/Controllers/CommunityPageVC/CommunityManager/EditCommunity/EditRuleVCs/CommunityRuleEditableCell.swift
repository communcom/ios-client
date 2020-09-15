//
//  CommunityRuleEditableCell.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunityRuleEditableCell: CommunityRuleCell {
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
        parentViewController?.showAlert(title: "remove rule".localized().uppercaseFirst, message: "do you really want to remove this rule?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion: { (index) in
            if index == 0 {
                self.rule?.notifyDeleted()
            }
        })
    }
    
    @objc func buttonEditDidTouch() {
        guard let rule = rule else {return}
        let vc = EditRuleVC(rule: rule)
        parentViewController?.show(vc, sender: nil)
    }
}
