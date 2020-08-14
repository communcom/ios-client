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
    
    override func setUpViews() {
        super.setUpViews()
        actionButton.setTitle("propose to ban".localized().uppercaseFirst, for: .normal)
    }
    
    override func setUpStackView() {
        super.setUpStackView()
        stackView.insertArrangedSubview(UIView.spacer(), at: 0)
        // TODO: Add list of report reasons
    }
    
    func setUp(with item: ResponseAPIContentGetReport) {
        let postView = addViewToMainView(type: CMPostView.self)
        var membersCount: UInt64?
        switch item.type {
        case "post" where item.post != nil:
            postView.setUp(post: item.post!)
            membersCount = item.post?.reports?.reportsCount
        case "comment" where item.comment != nil:
            postView.setUp(comment: item.comment!)
            membersCount = item.comment?.reports?.reportsCount
        default:
            mainView.isHidden = true
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
