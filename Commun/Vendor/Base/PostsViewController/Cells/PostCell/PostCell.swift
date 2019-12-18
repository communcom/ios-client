//
//  PostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

class PostCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    var post: ResponseAPIContentGetPost?
    let voteActionsContainerViewHeight: CGFloat = 35
    weak var delegate: PostCellDelegate?
    
    // MARK: - Subviews
    private func createDescriptionLabel() -> UILabel {
        UILabel.with(textSize: 12, weight: .medium, textColor: UIColor(hexString: "#A5A7BD")!, numberOfLines: 1)
    }
    
    lazy var metaView: PostMetaView = {
        // headerView for actionSheet
        let headerView = PostMetaView(height: 40)
        return headerView
    }()
    
    lazy var moreActionsButton: UIButton = {
        let button = UIButton(width: 40, height: 40)
        button.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var voteContainerView: VoteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    lazy var sharesCountLabel = self.createDescriptionLabel()
    lazy var shareButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "share-count"), for: .normal)
        button.addTarget(self, action: #selector(shareButtonTapped(button:)), for: .touchUpInside)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -11, left: -13, bottom: -11, right: -13)
        return button
    }()
    
    // Number of views
    lazy var viewsCountLabel = self.createDescriptionLabel()
    lazy var viewsCountButton: UIButton = {
        let button = UIButton(width: 24, height: 16)
        button.setImage(UIImage(named: "icon-views-count-gray-default"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -14, left: -10, bottom: -14, right: -10)
        return button
    }()

    // Number of comments
    lazy var commentsCountLabel = self.createDescriptionLabel()
    lazy var commentsCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "comment-count"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -11, left: -13, bottom: -11, right: -13)
        return button
    }()
    
    // MARK: - Layout
    override func setUpViews() {
        super.setUpViews()
        
        selectionStyle = .none
        
        // Meta view
        contentView.addSubview(metaView)
        metaView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        metaView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        // moreActionsButton
        contentView.addSubview(moreActionsButton)
        moreActionsButton.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        moreActionsButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)
        
        metaView.autoPinEdge(.trailing, to: .leading, of: moreActionsButton, withOffset: -8)
        
        // action buttons
        contentView.addSubview(voteContainerView)
        voteContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)

        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonTapped(button:)), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonTapped(button:)), for: .touchUpInside)

        // Shares
        contentView.addSubview(shareButton)
        shareButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        shareButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)

        // Comments
        contentView.addSubview(commentsCountLabel)
        commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: shareButton, withOffset: -23)
        commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        contentView.addSubview(commentsCountButton)
        commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: -8)
        commentsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        commentsCountButton.addTarget(self, action: #selector(commentCountsButtonDidTouch), for: .touchUpInside)
        
        // Views
        // temp hide
//        contentView.addSubview(viewsCountLabel)
//        viewsCountLabel.autoPinEdge(.trailing, to: .leading, of: commentsCountButton, withOffset: -23)
//        viewsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
//        contentView.addSubview(viewsCountButton)
//        viewsCountButton.autoPinEdge(.trailing, to: .leading, of: viewsCountLabel, withOffset: -8)
//        viewsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
//        viewsCountButton.addTarget(self, action: #selector(commentCountsButtonDidTouch), for: .touchUpInside)

        // separator
        let separatorView = UIView(height: 10)
        separatorView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        contentView.addSubview(separatorView)
        separatorView.autoPinEdge(.top, to: .bottom, of: voteContainerView, withOffset: 10)
        separatorView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // layout content
        layoutContent()
    }
    
    func layoutContent() {
        fatalError("must override")
    }
    
    // MARK: - Methods
    func setUp(with post: ResponseAPIContentGetPost) {
        self.post = post

        metaView.setUp(post: post)
        voteContainerView.setUp(with: post.votes, userID: post.author?.userId)

        // Comments count
        self.commentsCountLabel.text = "\(post.stats?.commentsCount ?? 0)"

        // Views count
        self.viewsCountLabel.text = "\(post.stats?.viewCount ?? 0)"

        // Shares count
        //TODO: change this number later
        self.sharesCountLabel.text = "\(post.stats?.viewCount ?? 0)"
    }
}
