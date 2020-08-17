//
//  ReportCell.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

protocol ReportCellDelegate: class {}

class ReportCell: CommunityManageCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ReportCellDelegate?
    lazy var reportsStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var reportsStackViewWrapper = reportsStackView.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    
    override func setUpViews() {
        super.setUpViews()
        actionButton.setTitle("propose to ban".localized().uppercaseFirst, for: .normal)
    }
    
    override func setUpStackView() {
        super.setUpStackView()
        stackView.insertArrangedSubview(UIView.spacer(), at: 0)
        stackView.insertArrangedSubview(reportsStackViewWrapper, at: 2)
    }
    
    func setUp(with item: ResponseAPIContentGetReport) {
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
    }
    
    override func actionButtonDidTouch() {
        // TODO: - Propose to ban
    }
}
