//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import ASSpinnerView

class CommentCell: MyTableViewCell, ListItemCellType {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    private let maxCharactersForReduction = 150
    let defaultContentFontSize: CGFloat = 15
    let embedSize = CGSize(width: 270, height: 180)
    let contentTextViewBackgroundColor = UIColor.f3f5fa
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    var expanded = false
    weak var delegate: CommentCellDelegate?
    var textViewToEmbedConstraint: NSLayoutConstraint?
    var showIndentForChildComment = true
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentTextView: UITextView = {
        let textView = UITextView(forExpandable: ())
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = contentTextViewBackgroundColor
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
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        
        contentView.addSubview(contentTextView)
        contentTextView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentTextView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentTextView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        
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
        replyButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        contentView.addSubview(timeLabel)
        timeLabel.autoPinEdge(.leading, to: .trailing, of: replyButton)
        timeLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        contentView.addSubview(statusImageView)
        statusImageView.autoPinEdge(.leading, to: .trailing, of: timeLabel, withOffset: 10)
        statusImageView.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        let constraint = statusImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        voteContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        
        // handle tap on see more
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextView(sender:)))
        contentTextView.addGestureRecognizer(tap)
    }
    
    // MARK: - Setup
    func setUp(with comment: ResponseAPIContentGetComment) {
        self.comment = comment
        
        // if comment is a reply
        if comment.parents.comment != nil && showIndentForChildComment {
            avatarImageView.leftConstraint?.constant = 72
        } else {
            avatarImageView.leftConstraint?.constant = 16
        }
//        leftPaddingConstraint.constant = CGFloat((comment.nestedLevel - 1 > 2 ? 2 : comment.nestedLevel - 1) * 72 + 16)
        
        // avatar
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl)
        
        // setContent
        setText()
        
        // loading handler
        statusImageView.removeSubviews()
        statusImageView.removeGestureRecognizers()
        statusImageView.isUserInteractionEnabled = false
        statusImageView.isHidden = true
        
        switch comment.sendingState {
        case .editing, .adding, .replying:
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
            
            replyButton.isEnabled = false
        case .error:
            statusImageView.widthConstraint?.constant = 16
            statusImageView.isHidden = false
            statusImageView.image = UIImage(named: "comment-posting-error")
            
            // handle error
            statusImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(retrySendingCommentDidTouch(gestureRecognizer:)))
            statusImageView.addGestureRecognizer(tap)
            
            replyButton.isEnabled = false
        default:
            statusImageView.widthConstraint?.constant = 0
            
            replyButton.isEnabled = true
        }
        
        // if comment was deleted
        if comment.document == nil {
            replyButton.isEnabled = false
        }
        
        // Show media
        let embededResult = comment.attachments
        gridView.isPostDetail = true
        if embededResult.count > 0 {
            textViewToEmbedConstraint?.constant = 5
            gridView.widthConstraint?.constant = embedSize.width
            gridView.heightConstraint?.constant = embedSize.height
            layoutIfNeeded()
            gridView.setUp(embeds: embededResult)
        } else {
            if let image = comment.placeHolderImage?.image {
                textViewToEmbedConstraint?.constant = 5
                gridView.widthConstraint?.constant = embedSize.width
                gridView.heightConstraint?.constant = embedSize.height
                layoutIfNeeded()
                gridView.setUp(placeholderImage: image)
            } else {
                textViewToEmbedConstraint?.constant = 0
                gridView.widthConstraint?.constant = 0
                gridView.heightConstraint?.constant = 0
                layoutIfNeeded()
            }
        }
        
        if (self.comment!.sendingState ?? MessageSendingState.none) != MessageSendingState.none ||
            comment.document == nil {
            // disable voting
            self.comment!.votes.isBeingVoted = true
        }
        voteContainerView.setUp(with: self.comment!.votes, userID: comment.author?.userId)
        timeLabel.text = " • " + Date.timeAgo(string: comment.meta.creationTime)
    }
    
    func setText() {
        let userId = comment?.author?.username ?? comment?.author?.userId ?? "Unknown user"
        let mutableAS = NSMutableAttributedString(string: userId, attributes: [
            .font: UIFont.boldSystemFont(ofSize: defaultContentFontSize),
            .foregroundColor: UIColor.black
        ])
        
        guard var content = comment?.document?.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize)],
            attachmentType: TextAttachment.self)
        else {
            mutableAS.append(NSAttributedString(string: " " + "this comment was deleted".localized().uppercaseFirst, attributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize), .foregroundColor: UIColor.lightGray]))
            contentTextView.attributedText = mutableAS
            return
        }
        
        // truncate last character
        if content.string.ends(with: "\r") {
            let newContent = NSMutableAttributedString(attributedString: content)
            newContent.deleteCharacters(in: NSRange(location: content.length - 1, length: 1))
            content = newContent
        }
        
        if content.string.trimmed == "" {
            contentTextView.backgroundColor = .clear
        } else {
            contentTextView.backgroundColor = .f3f5fa
        }
        
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
                        .foregroundColor: UIColor.appMainColor
                ])
            )

        contentTextView.attributedText = mutableAS
    }
}
