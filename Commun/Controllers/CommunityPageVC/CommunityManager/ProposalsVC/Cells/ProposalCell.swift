//
//  ProposalCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol ProposalCellDelegate: class {}

class ProposalCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ProposalCellDelegate?
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    lazy var metaView = PostMetaView(height: 40.0)
    lazy var actionTypeLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var mainView = UIView(forAutoLayout: ())
    
    lazy var voteContainerView: UIView = {
        let view = UIView(forAutoLayout: ())
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        let button = CommunButton.default(label: "accept".localized().uppercaseFirst)
        button.addTarget(self, action: #selector(acceptButtonDidTouch), for: .touchUpInside)
        stackView.addArrangedSubviews([voteLabel, button])
        return view
    }()
    lazy var voteLabel = UILabel.with(textSize: 15, numberOfLines: 2)
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appWhiteColor
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpStackView()
    }
    
    func setUpStackView() {
        let spacer = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        stackView.addArrangedSubviews([
            metaView.padding(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)),
            actionTypeLabel.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)),
            mainView,
            spacer,
            voteContainerView,
            UIView.spacer(height: 16, backgroundColor: .appLightGrayColor)
        ])
        
        stackView.setCustomSpacing(0, after: spacer)
        stackView.setCustomSpacing(0, after: voteContainerView)
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
        // meta view
        if item.contentType != "post" {
            metaView.setUp(with: item.community, author: item.proposer, creationTime: item.blockTime!)
        }
        
        var actionColor: UIColor = .appBlackColor
        var typePlainText = ""
        
        switch item.type {
        case "setInfo":
            if item.change?.subType == "remove" { actionColor = .red }
            typePlainText = "\(item.change?.subType ?? "change") \(item.change?.type ?? "")"
        case "banPost":
            typePlainText = "ban post"
        case "banComment":
            typePlainText = "ban comment"
        default:
            typePlainText = item.type ?? ""
        }
        
        // actionTypeLabel
        let actionText = NSMutableAttributedString()
            .text(typePlainText.localized().uppercaseFirst, size: 15, weight: .semibold, color: actionColor)
        
        let expiringDate = Date.from(string: item.expiration ?? "")
        if expiringDate < Date() {
            // expired
            actionText
                .text(" (\("expired".localized().uppercaseFirst))", size: 15, weight: .semibold, color: actionColor)
        } else {
            // expiring in
            actionText
                .text(" (\("expiring in".localized().uppercaseFirst) \(Date().intervalToDate(date: expiringDate)))", size: 15, weight: .medium, color: item.change?.subType == "remove" ? .red: .appGrayColor)
        }
        actionTypeLabel.attributedText = actionText
        
        // content view
        mainView.isHidden = false
        switch item.type {
        case "setInfo":
            setInfo(item)
        case "banPost":
            setBanPost(item.post)
        case "banComment":
            mainView.isHidden = true
        default:
            mainView.isHidden = true
        }
        
        // voteLabel
        voteLabel.attributedText = NSMutableAttributedString()
            .text("voted".localized().uppercaseFirst, size: 12, weight: .semibold, color: .appGrayColor)
            .normal("\n")
            .text("\(item.approvesCount ?? 0) \("from".localized()) \(item.approvesNeed ?? 0) \("votes".localized())", size: 14, weight: .semibold)
            .withParagraphStyle(lineSpacing: 4)
    }
    
    private func setBanPost(_ post: ResponseAPIContentGetPost?) {
        if !(mainView.subviews.first === CMPostView.self) {
            let postView = CMPostView(forAutoLayout: ())
            postView.metaView.isHidden = true
            addSubviewToMainView(postView)
        }
        guard let post = post, let postView = mainView.subviews.first as? CMPostView else {
            mainView.removeSubviews()
            return
        }
        metaView.setUp(post: post)
        postView.setUp(post: post)
    }
    
    private func setInfo(_ item: ResponseAPIContentGetProposal?) {
        let change = item?.change
        switch change?.type {
        case "rules":
            if !(mainView.subviews.first === RuleProposalView.self) {
                addSubviewToMainView(RuleProposalView(forAutoLayout: ()), contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            }
            guard let ruleView = mainView.subviews.first as? RuleProposalView
            else {
                mainView.isHidden = true
                return
            }
            ruleView.setUp(with: change?.new?.rules, oldRule: change?.old?.rules, subType: item?.change?.subType, isOldRuleCollapsed: change?.isOldRuleCollapsed ?? true)
            ruleView.collapsingHandler = {
                var item = item
                let value = item?.change?.isOldRuleCollapsed ?? true
                item?.change?.isOldRuleCollapsed = !value
                item?.notifyChanged()
            }
            return
        case "description":
            if !(mainView.subviews.first === DescriptionProposalView.self) {
                addSubviewToMainView(DescriptionProposalView(forAutoLayout: ()), contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            }
            guard let descriptionView = mainView.subviews.first as? DescriptionProposalView
            else {
                mainView.isHidden = true
                return
            }
            descriptionView.setUp(content: item?.change?.new?.string)
            return
        case "avatarUrl":
            if !(mainView.subviews.first === AvatarProposalView.self) {
                addSubviewToMainView(AvatarProposalView(forAutoLayout: ()), contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            }
            guard let avatarView = mainView.subviews.first as? AvatarProposalView
            else {
                mainView.isHidden = true
                return
            }
            avatarView.setUp(newAvatar: item?.change?.new?.string, oldAvatar: item?.change?.old?.string)
            return
        case "coverUrl":
            if !(mainView.subviews.first === CoverProposalView.self) {
                addSubviewToMainView(CoverProposalView(forAutoLayout: ()), contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            }
            guard let coverView = mainView.subviews.first as? CoverProposalView
            else {
                mainView.isHidden = true
                return
            }
            coverView.setUp(newCover: item?.change?.new?.string, oldCover: item?.change?.old?.string)
            return
        default:
            mainView.isHidden = true
        }
    }
    
    private func addSubviewToMainView(_ subview: UIView, contentInsets: UIEdgeInsets = .zero) {
        mainView.removeSubviews()
        mainView.addSubview(subview)
        subview.autoPinEdgesToSuperviewEdges(with: contentInsets)
    }
    
    @objc func acceptButtonDidTouch() {
        
    }
}
