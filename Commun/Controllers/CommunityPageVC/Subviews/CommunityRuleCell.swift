//
//  CommunityRuleCell.swift
//  Commun
//
//  Created by Chung Tran on 10/31/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CommunityRuleCell: CommunityPageCell {
    // MARK: - Properties
    var rowIndex: Int?
    var rule: ResponseAPIContentGetCommunityRule?
    
    // MARK: - Subviews
    lazy var containerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 14, alignment: .fill, distribution: .fill)
    lazy var titleLabel: UILabel = {
        let label = UILabel.with(textSize: 15.0, weight: .bold, numberOfLines: 0)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()
    lazy var contentLabel: UILabel = UILabel.with(textSize: 15.0, numberOfLines: 0)
    lazy var expandButton: UIButton = {
        let expandButton = UIButton.circleGray(imageName: "rule_expand")
        expandButton.addTarget(self, action: #selector(expandButtonDidTouch(_:)), for: .touchUpInside)
        return expandButton
    }()
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .clear
        // background color
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 10.0, right: 10.0))
        
        containerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16))
        
        let titleStackView = UIStackView(axis: .horizontal, spacing: 8, alignment: .top, distribution: .fill)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(expandButton)
        
        stackView.addArrangedSubviews([
            titleStackView,
            contentLabel
        ])
        
        contentLabel.isHidden = true
    }
    
    func setUp(with newRule: ResponseAPIContentGetCommunityRule?) {
        rule = newRule
        var titleText = ""
        if let index = rowIndex {
            titleText += "\(index + 1). "
        }
        titleText += (rule?.title ?? "")
        titleLabel.text = titleText
        expandButton.isHidden = (newRule?.text == nil) || (newRule?.text?.isEmpty ?? false)
        let isExpanded = (rule?.isExpanded ?? false)
        contentLabel.text = rule?.text
        contentLabel.isHidden = !isExpanded
        expandButton.transform = isExpanded ? .init(rotationAngle: -.pi) : .identity
    }
    
    @objc func expandButtonDidTouch(_ sender: UIButton) {
        let isExpanded = rule?.isExpanded ?? false
        rule?.isExpanded = !isExpanded
        rule?.notifyChanged()
    }
}
