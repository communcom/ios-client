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
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    lazy var metaView = PostMetaView(height: 40.0)
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
        stackView.addArrangedSubviews([
            metaView.wrapping(inset: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)),
            mainView,
            UIView.spacer(height: 2, backgroundColor: .appLightGrayColor),
            voteContainerView,
            UIView.spacer(height: 16, backgroundColor: .appLightGrayColor)
        ])
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
        // meta view
        if item.contentType != "post" {
            metaView.setUp(with: item.community, author: item.proposer, creationTime: item.blockTime!)
        }
        
        // voteLabel
        voteLabel.attributedText = NSMutableAttributedString()
            .text("voted".localized().uppercaseFirst, size: 12, weight: .semibold, color: .appGrayColor)
            .normal("\n")
            .text("\(item.approvesCount ?? 0) \("from".localized()) \(item.approvesNeed ?? 0) \("votes".localized())", size: 14, weight: .semibold)
            .withParagraphStyle(lineSpacing: 4)
        
        // item type
        
        switch item.action {
        case "ban":
            switch item.contentType {
            case "post":
                setUp(with: item.post)
                return
            default:
                // TODO:
                break
            }
        case "setinfo":
            setUp(with: item.change)
            return
        default:
            // TODO:
            break
        }
        mainView.removeSubviews()
    }
    
    private func setUp(with post: ResponseAPIContentGetPost?) {
        if !(mainView.subviews.first is CMPostView) {
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
    
    private func setUp(with change: ResponseAPIContentGetProposalChange?) {
        switch change?.type {
        case "rules":
            if !(mainView.subviews.first is RuleProposalView) {
                addSubviewToMainView(RuleProposalView(forAutoLayout: ()), contentInsets: UIEdgeInsets(inset: 16))
            }
            guard let rule = change?.new?.rules, let oldRule = change?.old?.rules, let ruleView = mainView.subviews.first as? RuleProposalView
            else {
                mainView.removeSubviews()
                return
            }
            ruleView.setUp(with: rule, oldRule: oldRule)
            return
        default:
            // TODO:
            break
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
