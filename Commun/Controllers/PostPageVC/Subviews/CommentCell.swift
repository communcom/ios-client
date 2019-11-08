//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol CommentCellDelegate: class {
    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedIndexes: [Int] {get set}
    var tableView: UITableView! {get set}
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnUserName userName: String)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
}

class CommentCell: MyTableViewCell {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    private let maxCharactersForReduction = 150
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    var expanded = false
    var themeColor = UIColor(hexString: "#6A80F5")!
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentContainerView = UIView(backgroundColor: .f3f5fa, cornerRadius: 12)
    lazy var contentLabel = UILabel.with(text: "Andrey Ivanov Welcome! 😄 Wow would love to wake", textSize: 15, numberOfLines: 0)
    lazy var embedView = UIView(width: 192, height: 101)
    lazy var voteContainerView: VoteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        contentContainerView.addSubview(contentLabel)
        contentLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)
        
        contentContainerView.addSubview(embedView)
        embedView.autoPinEdge(.leading, to: .leading, of: contentLabel)
        embedView.autoPinEdge(.top, to: .bottom, of: contentLabel)
        embedView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        
        contentView.addSubview(voteContainerView)
        
    }
    
    // MARK: - Setup
    func setup(with comment: ResponseAPIContentGetComment, expanded: Bool = false) {
        self.comment = comment
        self.expanded = expanded
        
        // if comment is a reply
        if comment.parents.comment != nil {
            leftPaddingConstraint.constant = 72
        } else {
            leftPaddingConstraint.constant = 16
        }
//        leftPaddingConstraint.constant = CGFloat((comment.nestedLevel - 1 > 2 ? 2 : comment.nestedLevel - 1) * 72 + 16)
        
        // avatar
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? comment.author?.userId ?? "U")
        
        // setContent
        setText(expanded: expanded)
        
        // Show media
        let embededResult = comment.attachments.first
        
        if embededResult?.type == "image",
            let urlString = embededResult?.attributes?.thumbnail_url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            embedViewHeightConstraint.constant = 101
            embedView.trailingAnchor.constraint(equalTo: embedView.superview!.trailingAnchor, constant: -10).isActive = true
        } else {
            // TODO: Video
            embedViewHeightConstraint.constant = 0
            if let constraint = embedView.constraints.first(where: {$0.firstAttribute == .trailing}) {
                embedView.removeConstraint(constraint)
            }
        }
        
        #warning("change this number later")
        voteCountLabel.text = "\((comment.votes.upCount ?? 0) - (comment.votes.downCount ?? 0))"
        
        upVoteButton.tintColor = comment.votes.hasUpVote ?? false ? themeColor: .lightGray
        downVoteButton.tintColor = comment.votes.hasDownVote ?? false ? themeColor: .lightGray
        
        timeLabel.text = Date.timeAgo(string: comment.meta.creationTime)
        
        // observe changge
        observeCommentChanged()
    }
}
