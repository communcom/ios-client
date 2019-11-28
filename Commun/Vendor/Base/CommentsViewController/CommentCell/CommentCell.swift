//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import ASSpinnerView

protocol CommentCellDelegate: class {
//    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedComments: [ResponseAPIContentGetComment] {get set}
    var tableView: UITableView {get set}
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment)
}

class CommentCell: MyTableViewCell, CommentController {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    private let maxCharactersForReduction = 150
    let defaultContentFontSize: CGFloat = 15
    let embedSize = CGSize(width: 270, height: 180)
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    var expanded = false
    var themeColor = UIColor(hexString: "#6A80F5")!
    weak var delegate: CommentCellDelegate?
    var textViewToEmbedConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentTextView: UITextView = {
        let textView = UITextView(forExpandable: ())
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.backgroundColor = .f3f5fa
        textView.textContainerInset = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        textView.cornerRadius = 12
        return textView
    }()
    lazy var gridView = GridView(width: embedSize.width, height: embedSize.height, cornerRadius: 12)
    lazy var voteContainerView: VoteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    lazy var replyButton = UIButton(label: "reply".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
    lazy var timeLabel = UILabel.with(text: " • 3h", textSize: 13, weight: .bold, textColor: .a5a7bd)
    lazy var statusImageView = UIImageView(width: 16, height: 16, cornerRadius: 8)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        contentView.addSubview(contentTextView)
        contentTextView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentTextView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        contentTextView.delegate = self
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnTextView))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        contentTextView.addGestureRecognizer(lpgr)
        
        contentView.addSubview(gridView)
        gridView.autoPinEdge(.leading, to: .leading, of: contentTextView)
        textViewToEmbedConstraint = gridView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 5)
        gridView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
            .isActive = true
        
        contentView.addSubview(voteContainerView)
        voteContainerView.autoPinEdge(.top, to: .bottom, of: gridView, withOffset: 5)
        voteContainerView.autoPinEdge(.leading, to: .leading, of: contentTextView)
        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch), for: .touchUpInside)
        
        contentView.addSubview(replyButton)
        replyButton.autoPinEdge(.leading, to: .trailing, of: voteContainerView, withOffset: 10)
        replyButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        replyButton.addTarget(self, action: #selector(replyButtonDidTouch), for: .touchUpInside)
        
        contentView.addSubview(timeLabel)
        timeLabel.autoPinEdge(.leading, to: .trailing, of: replyButton)
        timeLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        contentView.addSubview(statusImageView)
        statusImageView.autoPinEdge(.leading, to: .trailing, of: timeLabel, withOffset: 10)
        statusImageView.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        statusImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4)
            .isActive = true
        
        #warning("answers...")
        voteContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
    
    // MARK: - Setup
    func setUp(with comment: ResponseAPIContentGetComment?) {
        guard let comment = comment else {return}
        self.comment = comment
        
        // if comment is a reply
        if comment.parents.comment != nil {
            avatarImageView.leftConstraint?.constant = 72
        } else {
            avatarImageView.leftConstraint?.constant = 16
        }
//        leftPaddingConstraint.constant = CGFloat((comment.nestedLevel - 1 > 2 ? 2 : comment.nestedLevel - 1) * 72 + 16)
        
        // avatar
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? comment.author?.userId ?? "U")
        
        // setContent
        setText()
        
        // loading handler
        let isEditing = comment.isEditing ?? false
        let hasError = comment.hasError ?? false
        
        if isEditing {
            statusImageView.widthConstraint?.constant = 16
            statusImageView.backgroundColor = .clear
            statusImageView.isHidden = false
            statusImageView.image = nil
            let spinnerView = ASSpinnerView()
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            spinnerView.spinnerLineWidth = 2
            spinnerView.spinnerDuration = 0.3
            spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
            statusImageView.addSubview(spinnerView)
            spinnerView.autoPinEdgesToSuperviewEdges()
        }
        else if hasError  {
            statusImageView.widthConstraint?.constant = 16
            statusImageView.isHidden = false
            statusImageView.image = UIImage(named: "!")
            statusImageView.tintColor = .white
            statusImageView.backgroundColor = .a5a7bd
            statusImageView.removeSubviews()
        }
        else {
            statusImageView.widthConstraint?.constant = 0
            statusImageView.backgroundColor = .a5a7bd
            statusImageView.isHidden = true
            statusImageView.removeSubviews()
        }
        
        // Show media
        let embededResult = comment.attachments
        if embededResult.count > 0 {
            textViewToEmbedConstraint?.constant = 5
            gridView.widthConstraint?.constant = embedSize.width
            gridView.heightConstraint?.constant = embedSize.height
            layoutIfNeeded()
            gridView.setUp(embeds: embededResult)
        }
        else {
            textViewToEmbedConstraint?.constant = 0
            gridView.widthConstraint?.constant = 0
            gridView.heightConstraint?.constant = 0
            layoutIfNeeded()
        }
        
        voteContainerView.setUp(with: comment.votes)
        timeLabel.text = " • " + Date.timeAgo(string: comment.meta.creationTime)
    }
    
    func setText() {
        guard let content = comment?.document.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize)],
            attachmentType: TextAttachment.self)
        else {return}
        
        if content.string.trimmed == "" {
            contentTextView.backgroundColor = .clear
        }
        else {
            contentTextView.backgroundColor = .f3f5fa
        }
        
        let userId = comment?.author?.username ?? comment?.author?.userId ?? "Unknown user"
        let mutableAS = NSMutableAttributedString(string: userId, attributes: [
            .font: UIFont.boldSystemFont(ofSize: defaultContentFontSize),
            .link: "https://commun.com/@\(comment?.author?.userId ?? comment?.author?.username ?? "unknown-user")"
        ])
        
        mutableAS.append(NSAttributedString(string: " "))
        
        // If text is not so long or expanded
        if content.string.count < maxCharactersForReduction || expanded {
            mutableAS.append(content)
            contentTextView.attributedText = mutableAS
            return
        }
        
        // If doesn't expanded
        let contentAS = NSAttributedString(
            string: String(content.string.prefix(maxCharactersForReduction - 3)),
            attributes: [
                .font: UIFont.systemFont(ofSize: defaultContentFontSize)
            ])
        mutableAS.append(contentAS)
        
        // add see more button
        mutableAS
            .normal("...")
            .append(
                NSAttributedString(
                    string: "see more".localized().uppercaseFirst,
                    attributes: [
                        .link: "seemore://",
                        .foregroundColor: themeColor
                ])
            )


        contentTextView.attributedText = mutableAS
    }
}
