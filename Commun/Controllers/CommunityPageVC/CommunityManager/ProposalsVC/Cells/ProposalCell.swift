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
            typePlainText = "ban \(item.contentType ?? "post")"
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
            setBanPost(item)
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
    
    private func setBanPost(_ item: ResponseAPIContentGetProposal?) {
        let postView = addViewToMainView(type: CMPostView.self)
        postView.headerView.isHidden = true
        
        if let post = item?.post {
            metaView.setUp(post: post)
            postView.setUp(post: post)
        } else if let comment = item?.comment {
            metaView.setUp(comment: comment)
            postView.setUp(comment: comment)
        } else {
            let label = UILabel.with(text: "\(item?.postLoadingError != nil ? "Error: \(item!.postLoadingError!)" : "loading".localized().uppercaseFirst + "...")", textSize: 15, weight: .semibold, numberOfLines: 0)
            mainView.removeSubviews()
            mainView.addSubview(label)
            label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 32, vertical: 0))
        }
    }
    
    private func setInfo(_ item: ResponseAPIContentGetProposal?) {
        let change = item?.change
        switch change?.type {
        case "rules":
            let ruleView = addViewToMainView(type: RuleProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            ruleView.setUp(with: change?.new?.rules, oldRule: change?.old?.rules, subType: item?.change?.subType, isOldRuleCollapsed: change?.isOldRuleCollapsed ?? true)
            ruleView.collapsingHandler = {
                var item = item
                let value = item?.change?.isOldRuleCollapsed ?? true
                item?.change?.isOldRuleCollapsed = !value
                item?.notifyChanged()
            }
            return
        case "description":
            let descriptionView = addViewToMainView(type: DescriptionProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            
            descriptionView.setUp(content: item?.change?.new?.string)
            return
        case "avatarUrl":
            let avatarView = addViewToMainView(type: AvatarProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            avatarView.setUp(newAvatar: item?.change?.new?.string, oldAvatar: item?.change?.old?.string)
            return
        case "coverUrl":
            let coverView = addViewToMainView(type: CoverProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            coverView.setUp(newCover: item?.change?.new?.string, oldCover: item?.change?.old?.string)
            return
        default:
            mainView.isHidden = true
        }
    }
    
    @objc func acceptButtonDidTouch() {
        
    }
    
    // MARK: - Helper
    @discardableResult
    private func addViewToMainView<T: UIView>(type: T.Type, contentInsets: UIEdgeInsets = .zero) -> T {
        if !(mainView.subviews.first === T.self) {
            let view = T(forAutoLayout: ())
            mainView.removeSubviews()
            mainView.addSubview(view)
            view.autoPinEdgesToSuperviewEdges(with: contentInsets)
        }
        
        let view = mainView.subviews.first as! T
        return view
    }
}
