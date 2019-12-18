//
//  PostHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class PostHeaderView: MyTableHeaderView, PostController {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var post: ResponseAPIContentGetPost?
    
    // MARK: - Subviews
    lazy var titleLabel = UILabel.with(text: "Discussion - The Dangerous Path Overwatch is Headed: Giving Players", textSize: 21, weight: .bold, numberOfLines: 0)
    
    lazy var contentTextView = PostHeaderTextView(forExpandable: ())
    
    lazy var voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    lazy var viewsCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "icon-views-count-gray-default"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -13, left: -12, bottom: -13, right: -12)
        return button
    }()
    
    lazy var viewsCountLabel = UILabel.with(text: "1.2k", textSize: 12, weight: .medium, textColor: UIColor(hexString: "#A5A7BD")!, numberOfLines: 1)
    
    lazy var commentsCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "comment-count"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -13, left: -12, bottom: -13, right: -12)
        return button
    }()
    
    lazy var commentsCountLabel = UILabel.with(text: "12k", textSize: 12, weight: .medium, textColor: UIColor(hexString: "#A5A7BD")!, numberOfLines: 1)
    
    lazy var sharesCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "share-count"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -13, left: -12, bottom: -13, right: -12)
        return button
    }()
    
//    lazy var sortButton = RightAlignedIconButton(imageName: "small-down-arrow", label: "interesting first".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor, contentInsets: UIEdgeInsets(horizontal: 8, vertical: 0))
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .bottom)
        
        addSubview(contentTextView)
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        contentTextView.autoPinEdge(toSuperviewEdge: .leading)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing)
        contentTextView.delegate = self
        
        addSubview(voteContainerView)
        voteContainerView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 10)
        voteContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch(_:)), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch(_:)), for: .touchUpInside)

        addSubview(sharesCountButton)
        sharesCountButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sharesCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        sharesCountButton.addTarget(self, action: #selector(shareButtonDidTouch(_:)), for: .touchUpInside)
        
        addSubview(commentsCountLabel)
        commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: sharesCountButton, withOffset: -23)
        commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        addSubview(commentsCountButton)
        commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: -8)
        commentsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        // Views count
        // temp hide
//        addSubview(viewsCountLabel)
//        viewsCountLabel.autoPinEdge(.trailing, to: .leading, of: commentsCountButton, withOffset: -23)
//        viewsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
//
//        addSubview(viewsCountButton)
//        viewsCountButton.autoPinEdge(.trailing, to: .leading, of: viewsCountLabel, withOffset: -8)
//        viewsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        let commentsLabel = UILabel.with(text: "comments".localized().uppercaseFirst, textSize: 21, weight: .bold)
        addSubview(commentsLabel)
        commentsLabel.autoPinEdge(.top, to: .bottom, of: voteContainerView, withOffset: 20)
        commentsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
//        addSubview(sortButton)
//        sortButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
//        sortButton.autoAlignAxis(.horizontal, toSameAxisOf: commentsLabel)
        
        // Pin bottom
        commentsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        // observe
        observePostChange()
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        self.post = post
        
        if post.document?.attributes?.type == "article" {
            // Show title
            titleLabel.text = post.document?.attributes?.title
        } else {
            titleLabel.text = nil
        }
        
        // Comments count
        commentsCountLabel.text = "\(post.stats?.commentsCount ?? 0)"
        
        // Views count
        viewsCountLabel.text = "\(post.stats?.viewCount ?? 0)"
        
        // Votes
        voteContainerView.setUp(with: post.votes, userID: post.author?.userId)
        
        // Show content
        // Parse data
        let attributedString = post.document?.toAttributedString(
            currentAttributes: contentTextView.defaultAttributes,
            attachmentSize: contentTextView.attachmentSize,
            attachmentType: PostPageTextAttachment.self)
        
        contentTextView.attributedText = attributedString
        layoutSubviews()
    }
    
    // MARK: - Actions
    @objc func upVoteButtonDidTouch(_ sender: Any) {
        upVote()
    }
    
    @objc func downVoteButtonDidTouch(_ sender: Any) {
        downVote()
    }
    
    @objc func shareButtonDidTouch(_ sender: Any) {
        sharePost()
    }
}
