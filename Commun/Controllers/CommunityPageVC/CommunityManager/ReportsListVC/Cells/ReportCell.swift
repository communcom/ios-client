//
//  ReportCell.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

protocol ReportCellDelegate: class {
    var items: [ResponseAPIContentGetReport] {get}
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
}

extension ReportCellDelegate where Self: BaseViewController {
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard let report = items.first(where: {$0.identity == identity}) else {return}
        
        if let proposal = report.proposal {
            let isApproved = proposal.isApproved ?? false
            if isApproved {
                // TODO: - refuse Ban
            } else {
                // TODO: - approve Ban
            }
        } else {
            // TODO: - create ban proposal
        }
    }
    
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard var report = items.first(where: {$0.identity == identity}),
            let proposal = report.proposal
        else {return}
        
        showAlert(title: "ban action".localized().uppercaseFirst, message: "do you really want to ban this content?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                report.isPerformingAction = true
                report.notifyChanged()
                
                BlockchainManager.instance.banContent(proposal.proposalId, communityCode: proposal.community?.communityId ?? "", commnityIssuer: report.proposal?.proposer?.userId ?? "", permlink: proposal.data?.message_id?.permlink ?? "")
                    .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                    .subscribe(onCompleted: {
                        report.isPerformingAction = false
                        report.notifyChanged()
                    }) { (error) in
                        self.showError(error)
                        report.isPerformingAction = false
                        report.notifyChanged()
                    }
                    .disposed(by: self.disposeBag)
            }
        }
    }
}

class ReportCell: CommunityManageCell, ListItemCellType {
    // MARK: - Properties
    var itemIdentity: ResponseAPIContentGetReport.Identity?
    weak var delegate: ReportCellDelegate?
    lazy var reportsStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var reportsStackViewWrapper = reportsStackView.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    lazy var banButton = CommunButton(height: 35, label: "ban action".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .red, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
    lazy var approvesCountLabel = UILabel.with(textSize: 15, numberOfLines: 2)
    
    override func setUpViews() {
        super.setUpViews()
        bottomStackView.addArrangedSubview(banButton)
        bottomStackView.insertArrangedSubview(approvesCountLabel, at: 1)
        banButton.addTarget(self, action: #selector(banButtonDidTouch), for: .touchUpInside)
        
        // bottomStackView fix
        voteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        approvesCountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        banButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override func setUpStackView() {
        super.setUpStackView()
        stackView.insertArrangedSubview(UIView.spacer(), at: 0)
        stackView.insertArrangedSubview(reportsStackViewWrapper, at: 2)
    }
    
    func setUp(with item: ResponseAPIContentGetReport) {
        self.itemIdentity = item.identity
        let postView = addViewToMainView(type: CMPostView.self)
        var membersCount: UInt64?
        var reports = [ResponseAPIContentGetEntityReport]()
        switch item.type {
        case "post" where item.post != nil:
            postView.setUp(post: item.post!)
            membersCount = item.post?.reports?.reportsCount
            reports = item.post!.reports?.items ?? []
        case "comment" where item.comment != nil:
            postView.setUp(comment: item.comment!)
            membersCount = item.comment?.reports?.reportsCount
            reports = item.comment!.reports?.items ?? []
        default:
            mainView.isHidden = true
        }
        
        if reports.isEmpty {
            reportsStackViewWrapper.isHidden = true
        } else {
            reports = Array(reports.prefix(3))
            reportsStackViewWrapper.isHidden = false
            
            // remove unrelated subviews
            var addedReports = [ResponseAPIContentGetEntityReport]()
            reportsStackView.arrangedSubviews.forEach {subview in
                let reportDetailView = subview as! ReportDetailView
                guard let report = reportDetailView.report else {
                    subview.removeFromSuperview()
                    return
                }
                if !reports.contains(report) {
                    subview.removeFromSuperview()
                }
                addedReports.append(report)
            }
            
            // add subviews
            let views = reports.filter {!addedReports.contains($0)}.map {report -> ReportDetailView in
                let view = ReportDetailView(forAutoLayout: ())
                view.setUp(with: report)
                return view
            }
            reportsStackView.addArrangedSubviews(views)
        }

        // voteLabel
        voteLabel.attributedText = NSMutableAttributedString()
            .text("reports".localized().uppercaseFirst, size: 12, weight: .semibold, color: .appGrayColor)
            .normal("\n")
            .text("\(membersCount ?? 0) " + String(format: NSLocalizedString("members-count", comment: ""), membersCount ?? 0), size: 14, weight: .semibold)
            .withParagraphStyle(lineSpacing: 4)
        
        // proposal buttons
        let isApproved = item.proposal?.isApproved ?? false
        actionButton.setHightLight(isApproved, highlightedLabel: "refuse Ban", unHighlightedLabel: item.proposal == nil ? "create Ban Proposal" : "approve Ban")
        actionButton.isEnabled = !(item.isPerformingAction ?? false)
        banButton.isEnabled = !(item.isPerformingAction ?? false)
        
        // ban buttons
        if let approvesCount = item.proposal?.approvesCount,
            let approvesNeed = item.proposal?.approvesNeed,
            approvesNeed > 0
        {
            banButton.isHidden = approvesCount < approvesNeed
            approvesCountLabel.isHidden = false
            approvesCountLabel.text = "\("approves count".localized().uppercaseFirst): \(approvesCount)/\(approvesNeed)"
        } else {
            banButton.isHidden = true
            approvesCountLabel.isHidden = true
        }
    }
    
    override func actionButtonDidTouch() {
        guard let identity = itemIdentity else {return}
        delegate?.buttonProposalDidTouch(forItemWithIdentity: identity)
    }
    
    @objc func banButtonDidTouch() {
        guard let identity = itemIdentity else {return}
        delegate?.buttonBanDidTouch(forItemWithIdentity: identity)
    }
}
