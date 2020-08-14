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

        reportsStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
        reportsStackViewWrapper.isHidden = true
        if !reports.isEmpty {
            reportsStackViewWrapper.isHidden = false
            let reportViews = reports.map { report -> UIView in
                let view = UIView(backgroundColor: UIColor(hexString: "#F9A468")!.inDarkMode(#colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1568627451, alpha: 1)).withAlphaComponent(0.1), cornerRadius: 10)
                let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .top, distribution: .fill)
                view.addSubview(stackView)
                stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
                let leftView = UIView(width: 2, height: 15, backgroundColor: UIColor(hexString: "#F9A568")!).padding(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
                let avatarImageView = MyAvatarImageView(size: 30)
                avatarImageView.setAvatar(urlString: report.author.avatarUrl)
                let label = UILabel.with(textSize: 15, numberOfLines: 0)
                label.attributedText = NSMutableAttributedString()
                    .text(report.author.username ?? report.author.userId, weight: .bold)
                    .text(" ")
                    .text(report.reason)
                stackView.addArrangedSubviews([leftView, avatarImageView, label])
                return view
            }
            reportsStackView.addArrangedSubviews(reportViews)
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
