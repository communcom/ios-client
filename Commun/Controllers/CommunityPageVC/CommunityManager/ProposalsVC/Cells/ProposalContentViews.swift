//
//  RuleProposalView.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ProposalView: MyView {
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
}

class DescriptionProposalView: ProposalView {
    // MARK: - Subviews
    lazy var contentLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    
    override func commonInit() {
        super.commonInit()
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
                expandButton.transform = .identity
                oldRuleTitleLabel.text = nil
                oldRuleContentLabel.text = nil
                oldRuleTitleLabel.isHidden = true
                oldRuleContentLabel.isHidden = true
            } else {
                expandButton.transform = CGAffineTransform(rotationAngle: -.pi)
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

class AvatarProposalView: ProposalView {
    lazy var oldAvatarImageView = MyAvatarImageView(size: 80)
    lazy var newAvatarImageView = MyAvatarImageView(size: 80)
    
    override func commonInit() {
        super.commonInit()
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
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

class CoverProposalView: ProposalView {
    lazy var coverPreviewImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 345 / 150).isActive = true
        return imageView
    }()
    lazy var oldCoverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 165 / 75).isActive = true
        return imageView
    }()
    lazy var newCoverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 165 / 75).isActive = true
        imageView.borderWidth = 2
        imageView.borderColor = .appMainColor
        return imageView
    }()
    
    override func commonInit() {
        super.commonInit()
        
        let oldCoverContainerView: UIView = createContainerView(title: "old cover", imageView: oldCoverImageView)
        let newCoverContainerView: UIView = createContainerView(title: "new cover", imageView: newCoverImageView, titleColor: .appMainColor)
        
        let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .fill, distribution: .fillEqually)
        hStack.addArrangedSubviews([oldCoverContainerView, newCoverContainerView])
        
        stackView.addArrangedSubviews([
            coverPreviewImageView,
            hStack
        ])
    }
    
    func setUp(newCover: String?, oldCover: String?) {
        coverPreviewImageView.setCover(urlString: newCover)
        newCoverImageView.setCover(urlString: newCover)
        oldCoverImageView.setCover(urlString: oldCover)
    }
    
    private func createContainerView(title: String, imageView: UIImageView, titleColor: UIColor = .appBlackColor) -> UIStackView {
        
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .center, distribution: .fill)
        
        let titleLabel = UILabel.with(text: title.localized().uppercaseFirst, textSize: 14, weight: .medium, textColor: titleColor)
        
        stackView.addArrangedSubviews([titleLabel, imageView])
        
        return stackView
    }
}

class LanguageProposalView: ProposalView {
    lazy var newLanguageView = CMLanguageView(forAutoLayout: ())
    lazy var oldLanguageView = CMLanguageView(forAutoLayout: ())
    
    override func commonInit() {
        super.commonInit()
        
        let newLanguageLabel = UILabel.with(text: "new language".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        let oldLanguageLabel = UILabel.with(text: "old language".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        
        stackView.addArrangedSubviews([
            newLanguageLabel,
            newLanguageView,
            oldLanguageLabel,
            oldLanguageView
        ])
    }
    
    func setUp(newLanguageCode: String?, oldLanguageCode: String?) {
        guard let newLanguage = Language.supported.first(where: {$0.code == newLanguageCode}),
            let oldLanguage = Language.supported.first(where: {$0.code == oldLanguageCode})
        else {
            newLanguageView.languageName.text = newLanguageCode
            oldLanguageView.languageName.text = oldLanguageCode
            return
        }
        newLanguageView.setUp(with: newLanguage)
        oldLanguageView.setUp(with: oldLanguage)
    }
}

class BanUserProposalView: ProposalView {
    lazy var userView = SubscribersCell(forAutoLayout: ())
        .configureToUseAsNormalView()
    lazy var reasonLabel = UILabel.with(textSize: 15, numberOfLines: 0)
    
    override func commonInit() {
        super.commonInit()
        stackView.addArrangedSubview(userView)
        stackView.addArrangedSubview(reasonLabel.padding(UIEdgeInsets(horizontal: 32, vertical: 0)))
    }
    
    func setUp(user: ResponseAPIContentGetProfile?, reasons: [String]) {
        guard let user = user else {return}
        userView.setUp(with: user)
        userView.actionButton.isHidden = true
        let reasons = reasons.map {$0.uppercaseFirst.localized()}
        reasonLabel.attributedText = NSMutableAttributedString()
            .text("reports-count".localizedPlural(reasons.count) + ": ", size: 15, weight: .medium)
            .text(reasons.joined(separator: ", "), size: 15, weight: .medium, color: .appMainColor)
        reasonLabel.isHidden = reasons.count == 0
    }
}
