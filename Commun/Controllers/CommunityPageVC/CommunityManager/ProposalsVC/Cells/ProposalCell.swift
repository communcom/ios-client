//
//  ProposalCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol ProposalCellDelegate: class {
    var items: [ResponseAPIContentGetProposal] {get}
    func buttonApproveDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity)
}

extension ProposalCellDelegate where Self: BaseViewController {
    func buttonApproveDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity) {
        guard var proposal = items.first(where: {$0.identity == identity}) else {return}
        let originIsApproved = proposal.isApproved ?? false
        
        // change state
        proposal.isBeingApproved = true
        proposal.isApproved = !originIsApproved
        proposal.approvesCount = originIsApproved ? (proposal.approvesCount ?? 1) - 1 : (proposal.approvesCount ?? 0) + 1
        proposal.notifyChanged()
        
        let request: Single<String>
        if originIsApproved {
            request = BlockchainManager.instance.unapproveProposal(proposal.proposalId)
        } else {
            request = BlockchainManager.instance.approveProposal(proposal.proposalId)
        }
        
        request
            .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
            .subscribe(onCompleted: {
                proposal.isBeingApproved = false
                proposal.notifyChanged()
            }) { (error) in
                self.showError(error)
                proposal.isBeingApproved = false
                proposal.isApproved = originIsApproved
                proposal.approvesCount = originIsApproved ? proposal.approvesCount! + 1 : proposal.approvesCount! - 1
                proposal.notifyChanged()
            }
            .disposed(by: disposeBag)
    }
}

class ProposalCell: CommunityManageCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ProposalCellDelegate?
    var itemIdentity: ResponseAPIContentGetProposal.Identity?
    
    // MARK: - Subviews
    lazy var metaView = PostMetaView(height: 40.0)
    lazy var actionTypeLabel = UILabel.with(textSize: 15, weight: .semibold)
    
    override func setUpViews() {
        super.setUpViews()
        actionButton.setTitle("accept".localized().uppercaseFirst, for: .normal)
    }
    
    override func setUpStackView() {
        super.setUpStackView()
        stackView.insertArrangedSubview(actionTypeLabel.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)), at: 0)
        stackView.insertArrangedSubview(metaView.padding(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)), at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let identity = itemIdentity else {return}
//        print("ProposalCellHeight: \(itemIdentity ?? "") \(bounds.height)")
        ResponseAPIContentGetProposal.height(of: identity, didChangeTo: bounds.height)
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
        itemIdentity = item.identity
        
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
            setMessage(item: item)
        default:
            mainView.isHidden = true
        }
        
        // voteLabel
        voteLabel.attributedText = NSMutableAttributedString()
            .text("voted".localized().uppercaseFirst, size: 12, weight: .semibold, color: .appGrayColor)
            .normal("\n")
            .text("\(item.approvesCount ?? 0) \("from".localized()) \(item.approvesNeed ?? 0) \("votes".localized())", size: 14, weight: .semibold)
            .withParagraphStyle(lineSpacing: 4)
        
        // button
        let joined = item.isApproved ?? false
        actionButton.setHightLight(joined, highlightedLabel: "approved", unHighlightedLabel: "approve")
        actionButton.isEnabled = !(item.isBeingApproved ?? false)
    }
    
    func setMessage(item: ResponseAPIContentGetProposal?) {
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
    
    override func actionButtonDidTouch() {
        guard let identity = itemIdentity else {return}
        actionButton.animate {
            self.delegate?.buttonApproveDidTouch(forItemWithIdentity: identity)
        }
    }
}
