//
//  RuleProposalView.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DescriptionProposalView: MyView {
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    lazy var contentLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.addArrangedSubviews([
            contentLabel
        ])
    }
    
    func setUp(content: String?) {
        contentLabel.text = content
    }
}

class RuleProposalView: DescriptionProposalView {
    // MARK: - Handler
    var collapsingHandler: (() -> Void)?
    
    // MARK: - Subviews
    lazy var titleLabel = UILabel.with(textSize: 17, weight: .semibold, numberOfLines: 0)
    lazy var oldRuleSection: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.addArrangedSubviews([
            UILabel.with(text: "old rule".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor),
            expandButton
        ])
        return stackView
    }()
    lazy var expandButton: UIButton = {
        let button = UIButton.circleGray(size: 24, imageName: "drop-down")
        button.addTarget(self, action: #selector(collapseButtonDidTouch), for: .touchUpInside)
        return button
    }()
    lazy var oldRuleTitleLabel = UILabel.with(textSize: 17, weight: .semibold, numberOfLines: 0)
    lazy var oldRuleContentLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    
    override func commonInit() {
        super.commonInit()
        stackView.insertArrangedSubview(titleLabel, at: 0)
        stackView.addArrangedSubviews([
            oldRuleSection,
            oldRuleTitleLabel,
            oldRuleContentLabel
        ])
    }
    
    func setUp(with rule: ResponseAPIGetCommunityRule?, oldRule: ResponseAPIGetCommunityRule?, subType: String?, isOldRuleCollapsed: Bool) {
        // clean
        oldRuleSection.isHidden = (subType != "update")
        if subType != "update" {
            oldRuleTitleLabel.isHidden = true
            oldRuleContentLabel.isHidden = true
        }
        oldRuleTitleLabel.text = nil
        oldRuleContentLabel.text = nil
        
        // title, content
        titleLabel.text = subType != "remove" ? rule?.title: oldRule?.title
        contentLabel.text = subType != "remove" ? rule?.text: oldRule?.text
        
        if !oldRuleSection.isHidden {
            if isOldRuleCollapsed == true {
                UIView.transition(with: expandButton, duration: expandButton.transform == .identity ? 0 : 0.3, options: .curveEaseInOut, animations: {
                    self.expandButton.transform = .identity
                })
                self.oldRuleTitleLabel.isHidden = true
                self.oldRuleContentLabel.isHidden = true
            } else {
                UIView.transition(with: expandButton, duration: expandButton.transform == CGAffineTransform(rotationAngle: -.pi) ? 0 : 0.3, options: .curveEaseInOut, animations: {
                    self.expandButton.transform = CGAffineTransform(rotationAngle: -.pi)
                })
                oldRuleTitleLabel.isHidden = false
                oldRuleContentLabel.isHidden = false
                
                self.oldRuleTitleLabel.text = oldRule?.title
                self.oldRuleContentLabel.text = oldRule?.text
            }
        }
    }
    
    @objc func collapseButtonDidTouch() {
        collapsingHandler?()
    }
}
