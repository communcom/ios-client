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
    let embedSize = CGSize(width: 270, height: 315)
    let contentTextViewBackgroundColor = UIColor.appLightGrayColor
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    weak var delegate: CommentCellDelegate?
    var textViewToEmbedConstraint: NSLayoutConstraint?
    var showIndentForChildComment = true
    var donationViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var avatarImageView: MyAvatarImageView = {
        let avatarImageView = MyAvatarImageView(size: 35)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        return avatarImageView
    }()
    lazy var usernameLabel: UILabel = {
        let label = UILabel.with(textSize: defaultContentFontSize, weight: .bold, textColor: .appBlackColor)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        return label
    }()
    lazy var donationImageView: UIImageView = {
        let imageView = UIImageView(width: 12.83, height: 12.22, imageNamed: "coin-reward")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donationImageViewDidTouch)))
        return imageView
    }()

    lazy var contentTextView: UITextView = {
        let textView = UITextView(forExpandable: ())
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        textView.backgroundColor = .clear
        return textView
    }()
    lazy var gridView = GridView(width: embedSize.width, height: embedSize.height, cornerRadius: 12)
    lazy var voteContainerView: VoteContainerView = {
        let voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch), for: .touchUpInside)
        return voteContainerView
    }()
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel.with(text: " • 3h", textSize: 13, weight: .bold, textColor: .appGrayColor)
        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return timeLabel
    }()
    lazy var replyButton: UIButton = {
        let replyButton = UIButton(label: "reply".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
        replyButton.addTarget(self, action: #selector(replyButtonDidTouch), for: .touchUpInside)
        replyButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return replyButton
    }()
    lazy var separator = UILabel.with(text: " • ", textSize: 13, weight: .bold, textColor: .appGrayColor)
    lazy var donateButton: UIButton = {
        let button = UIButton(label: "donate".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
        button.addTarget(self, action: #selector(donateButtonDidTouch), for: .touchUpInside)
        return button
    }()
    lazy var statusImageView = UIImageView(width: 16, height: 16, cornerRadius: 8)
    lazy var donationView = DonationView()
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        backgroundColor = .appWhiteColor
        
        contentView.addSubview(avatarImageView)
        avatarImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8).isActive = true
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        let headerStackView: UIStackView = {
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            stackView.addArrangedSubviews([usernameLabel, donationImageView])
            return stackView
        }()
        
        let contentStackView: UIView = {
            let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .leading, distribution: .fill)
            stackView.addArrangedSubviews([
                headerStackView.padding(UIEdgeInsets(top: 7, left: 15, bottom: 0, right: 10)),
                contentTextView
            ])
            
            let view = UIView(backgroundColor: contentTextViewBackgroundColor, cornerRadius: 12)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges()
            return view
        }()
        contentView.addSubview(contentStackView)
        contentStackView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentStackView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        contentView.addSubview(gridView)
        gridView.autoPinEdge(.leading, to: .leading, of: contentTextView)
        textViewToEmbedConstraint = gridView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 5)
        gridView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
            .isActive = true
        
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdge(.top, to: .bottom, of: gridView, withOffset: 5)
        stackView.autoPinEdge(.leading, to: .leading, of: contentTextView)
        stackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        stackView.addArrangedSubviews([
            voteContainerView,
            timeLabel,
            replyButton,
            separator,
            donateButton,
            statusImageView]
        )
        
        let constraint = statusImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        stackView.setCustomSpacing(0, after: timeLabel)
        stackView.setCustomSpacing(0, after: replyButton)
        stackView.setCustomSpacing(0, after: separator)
        stackView.setCustomSpacing(10, after: donateButton)
        
        // donation buttons
        contentView.addSubview(donationView)
        donationViewTopConstraint = donationView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 0)
        donationView.autoAlignAxis(toSuperviewAxis: .vertical)
        donationView.autoPinEdge(.bottom, to: .top, of: voteContainerView, withOffset: -4)
        donationView.delegate = self
        
        donationView.senderView = voteContainerView.likeCountLabel
        
        for (i, button) in donationView.amountButtons.enumerated() {
            button.tag = i
            button.addTarget(self, action: #selector(donationAmountDidTouch(sender:)), for: .touchUpInside)
        }
        donationView.otherButton.tag = donationView.amountButtons.count
        donationView.otherButton.addTarget(self, action: #selector(donationAmountDidTouch(sender:)), for: .touchUpInside)
        
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
        
        let userId = comment.author?.username ?? comment.author?.userId ?? "Unknown user"
        usernameLabel.text = userId
        
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
            donateButton.isEnabled = false
        case .error:
            statusImageView.widthConstraint?.constant = 16
            statusImageView.isHidden = false
            statusImageView.image = UIImage(named: "comment-posting-error")
            
            // handle error
            statusImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(retrySendingCommentDidTouch(gestureRecognizer:)))
            statusImageView.addGestureRecognizer(tap)
            
            replyButton.isEnabled = false
            donateButton.isEnabled = false
        default:
            statusImageView.widthConstraint?.constant = 0
            
            replyButton.isEnabled = true
            donateButton.isEnabled = true
        }
        
        // if comment was deleted
        if comment.document == nil {
            replyButton.isEnabled = false
            donateButton.isEnabled = false
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
        
        donationView.isHidden = true
        donationViewTopConstraint?.isActive = false
        if comment.showDonationButtons == true,
            comment.author?.userId != Config.currentUser?.id
        {
            donationView.isHidden = false
            donationViewTopConstraint?.isActive = true
        }
        
        timeLabel.text = Date.timeAgo(string: comment.meta.creationTime) + " • "
        
        // Donation
        donationImageView.isHidden = comment.donationsCount == 0
        
        // if current user is the author
        if comment.author?.userId == Config.currentUser?.id {
            donateButton.isHidden = true
            separator.isHidden = true
        } else {
            donateButton.isHidden = false
            separator.isHidden = false
        }
    }
    
    func setText() {
        let mutableAS = NSMutableAttributedString()
        
        guard var content = comment?.document?.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize),
                                .foregroundColor: UIColor.appBlackColor],
            attachmentType: TextAttachment.self)
        else {
            mutableAS.append(NSAttributedString(string: " " + "this comment was deleted".localized().uppercaseFirst, attributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize), .foregroundColor: UIColor.appGrayColor]))
            contentTextView.attributedText = mutableAS
            contentTextView.backgroundColor = .appLightGrayColor
            return
        }
        
        // truncate last character
        if content.string.ends(with: "\r") {
            let newContent = NSMutableAttributedString(attributedString: content)
            newContent.deleteCharacters(in: NSRange(location: content.length - 1, length: 1))
            content = newContent
        }
        
        if content.string.trimmed == "" {
            contentTextView.backgroundColor = .appLightGrayColor
        } else {
            contentTextView.backgroundColor = .appLightGrayColor
        }
        
        // If text is not so long or expanded
        if content.string.count < maxCharactersForReduction || (comment?.isExpanded == true) {
            mutableAS.append(content)
            contentTextView.attributedText = mutableAS
            return
        }
        
        // If doesn't expanded
        let contentAS = NSAttributedString(
            string: String(content.string.prefix(maxCharactersForReduction - 3)),
            attributes: [
                .font: UIFont.systemFont(ofSize: defaultContentFontSize),
                .foregroundColor: UIColor.appBlackColor
            ])
        mutableAS.append(contentAS)
        
        // add see more button
        mutableAS
            .normal("...")
            .append(
                NSAttributedString(
                    string: String(format: "%@ %@", "see".localized().uppercaseFirst, "more".localized()),
                    attributes: [
                        .link: "seemore://",
                        .foregroundColor: UIColor.appMainColor
                ])
            )

        contentTextView.attributedText = mutableAS
    }
}

extension CommentCell: DonationViewDelegate {
    @objc func donationAmountDidTouch(sender: UIButton) {
        guard let symbol = comment?.community?.communityId,
            let comment = comment,
            let user = comment.author
        else {return}
        let amount = donationView.amounts[safe: sender.tag]?.double
        
        let donateVC = WalletDonateVC(selectedBalanceSymbol: symbol, user: user, message: comment, amount: amount)
        parentViewController?.show(donateVC, sender: nil)
    }
    
    func donationViewCloseButtonDidTouch(_ donationView: DonationView) {
        var comment = self.comment
        comment?.showDonationButtons = false
        comment?.notifyChanged()
    }
}
