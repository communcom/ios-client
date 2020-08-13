//
//  RuleProposalView.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class RuleProposalView: MyView {
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    lazy var titleLabel = UILabel.with(textSize: 17, weight: .semibold, numberOfLines: 0)
    lazy var contentLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    lazy var oldRuleSection: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.addArrangedSubviews([
            UILabel.with(text: "old rule".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor),
            expandButton
        ])
        return stackView
    }()
    lazy var expandButton = UIButton.circleGray(size: 24, imageName: "drop-down")
    lazy var oldRuleTitleLabel = UILabel.with(textSize: 17, weight: .semibold, numberOfLines: 0)
    lazy var oldRuleContentLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.addArrangedSubviews([
            titleLabel,
            contentLabel,
            oldRuleSection,
            oldRuleTitleLabel,
            oldRuleContentLabel
        ])
    }
    
    func setUp(with rule: ResponseAPIGetCommunityRule, oldRule: ResponseAPIGetCommunityRule) {
        
    }
}
