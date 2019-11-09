//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol CommentCellDelegate: class {
//    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedIndexes: [Int] {get set}
    var tableView: UITableView! {get set}
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
}

class CommentCell: MyTableViewCell, CommentController {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    private let maxCharactersForReduction = 150
    let defaultContentFontSize: CGFloat = 15
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    var expanded = false
    var themeColor = UIColor(hexString: "#6A80F5")!
    weak var delegate: CommentCellDelegate?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentContainerView = UIView(backgroundColor: .f3f5fa, cornerRadius: 12)
    lazy var contentTextView: UITextView = {
        let textView = UITextView(forExpandable: ())
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()
    lazy var embedView = UIView(width: 192, height: 101)
    lazy var voteContainerView: VoteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    lazy var replyButton = UIButton(label: "reply".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
    lazy var timeLabel = UILabel.with(text: " • 3h", textSize: 13, weight: .bold, textColor: .a5a7bd)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        contentContainerView.addSubview(contentTextView)
        contentTextView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)
        contentTextView.delegate = self
        
        contentContainerView.addSubview(embedView)
        embedView.autoPinEdge(.leading, to: .leading, of: contentTextView)
        embedView.autoPinEdge(.top, to: .bottom, of: contentTextView)
        embedView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        contentView.addSubview(voteContainerView)
        voteContainerView.autoPinEdge(.top, to: .bottom, of: contentContainerView, withOffset: 5)
        voteContainerView.autoPinEdge(.leading, to: .leading, of: contentContainerView)
        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch), for: .touchUpInside)
        
        contentView.addSubview(replyButton)
        replyButton.autoPinEdge(.leading, to: .trailing, of: voteContainerView, withOffset: 10)
        replyButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        contentView.addSubview(timeLabel)
        timeLabel.autoPinEdge(.leading, to: .trailing, of: replyButton)
        timeLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
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
        
        // Show media
        let embededResult = comment.attachments.first
        
        if embededResult?.type == "image",
            let urlString = embededResult?.attributes?.thumbnail_url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            embedView.heightConstraint?.constant = 101
        } else {
            // TODO: Video
            embedView.heightConstraint?.constant = 0
        }
        
        voteContainerView.setUp(with: comment.votes)
        timeLabel.text = " • " + Date.timeAgo(string: comment.meta.creationTime)
    }
    
    func showPhoto(with url: URL) {
        embedView.removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.addTapToViewer()
        
        embedView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: embedView.topAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor, constant: -8).isActive = true
        imageView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            self?.hideLoading()
        }
    }
    
    func setText() {
        guard let content = comment?.document.toAttributedString(currentAttributes: [.font: UIFont.systemFont(ofSize: defaultContentFontSize)]) else {return}
        
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
