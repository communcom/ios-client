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
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
        let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        hStack.addArrangedSubviews([
            UILabel.with(text: "old rule".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor),
            expandButton
        ])
        stackView.addArrangedSubviews([
            hStack,
            oldRuleTitleLabel,
            oldRuleContentLabel
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
        stackView.addArrangedSubview(oldRuleSection)
    }
    
    func setUp(with rule: ResponseAPIGetCommunityRule?, oldRule: ResponseAPIGetCommunityRule?, subType: String?, isOldRuleCollapsed: Bool) {
        // clean
        oldRuleSection.isHidden = (subType != "update")
        
        // title, content
        titleLabel.text = subType != "remove" ? rule?.title: oldRule?.title
        contentLabel.text = subType != "remove" ? rule?.text: oldRule?.text
        
        if !oldRuleSection.isHidden {
            if isOldRuleCollapsed == true {
                UIView.transition(with: expandButton, duration: expandButton.transform == .identity ? 0 : 0.3, options: .curveEaseInOut, animations: {
                    self.expandButton.transform = .identity
                })
                oldRuleTitleLabel.text = nil
                oldRuleContentLabel.text = nil
                oldRuleTitleLabel.isHidden = true
                oldRuleContentLabel.isHidden = true
            } else {
                UIView.transition(with: expandButton, duration: expandButton.transform == CGAffineTransform(rotationAngle: -.pi) ? 0 : 0.3, options: .curveEaseInOut, animations: {
                    self.expandButton.transform = CGAffineTransform(rotationAngle: -.pi)
                })
                oldRuleTitleLabel.text = oldRule?.title
                oldRuleContentLabel.text = oldRule?.text
                oldRuleTitleLabel.isHidden = false
                oldRuleContentLabel.isHidden = false
                
            }
        }
    }
    
    @objc func collapseButtonDidTouch() {
        collapsingHandler?()
    }
}

class AvatarProposalView: MyView {
    lazy var oldAvatarImageView = MyAvatarImageView(size: 80)
    lazy var newAvatarImageView = MyAvatarImageView(size: 80)
    
    override func commonInit() {
        super.commonInit()
        
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .fill, distribution: .fillEqually)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let oldAvatarContainerView: UIView = createContainerView(title: "old avatar", imageView: oldAvatarImageView)
        let newAvatarContainerView: UIView = createContainerView(title: "new avatar", imageView: newAvatarImageView, titleColor: .appMainColor)
        newAvatarContainerView.borderColor = .appMainColor
        newAvatarContainerView.borderWidth = 2
        
        stackView.addArrangedSubviews([oldAvatarContainerView, newAvatarContainerView])
    }
    
    func setUp(newAvatar: String?, oldAvatar: String?) {
        oldAvatarImageView.setAvatar(urlString: oldAvatar)
        newAvatarImageView.setAvatar(urlString: newAvatar)
    }
    
    private func createContainerView(title: String, imageView: MyAvatarImageView, titleColor: UIColor = .appBlackColor) -> UIView {
        let view = UIView(backgroundColor: .appLightGrayColor, cornerRadius: 10)
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 165 / 141).isActive = true
        
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .center, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoCenterInSuperview()
        
        let titleLabel = UILabel.with(text: title.localized().uppercaseFirst, textSize: 14, weight: .medium, textColor: titleColor)
        
        stackView.addArrangedSubviews([imageView, titleLabel])
        
        return view
    }
}
