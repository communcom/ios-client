//
//  PostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class PostCell: MyTableViewCell, PostController {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    var post: ResponseAPIContentGetPost?
    
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
        button.setImage(UIImage(named: "points"), for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var voteActionsContainerView: UIView = {
        let view = UIView(height: voteActionsContainerViewHeight)
        view.backgroundColor = UIColor(hexString: "#F3F5FA")
        view.cornerRadius = voteActionsContainerViewHeight / 2
        return view
    }()
    
    private var voteButton: UIButton {
        let button = UIButton(width: 38)
        return button
    }
    
    lazy var upVoteButton: UIButton! = {
        let button = voteButton
        button.imageEdgeInsets = UIEdgeInsets(top: 10.5, left: 10, bottom: 10.5, right: 18)
        button.setImage(UIImage(named: "upVote"), for: .normal)
        button.addTarget(self, action: #selector(upVoteButtonTapped(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var likeCountLabel = self.createDescriptionLabel()
    
    lazy var downVoteButton: UIButton! = {
        let button = voteButton
        button.imageEdgeInsets = UIEdgeInsets(top: 10.5, left: 18, bottom: 10.5, right: 10)
        button.addTarget(self, action: #selector(downVoteButtonTapped(button:)), for: .touchUpInside)
        button.setImage(UIImage(named: "downVote"), for: .normal)
        return button
    }()
    
    lazy var sharesCountLabel = self.createDescriptionLabel()
    lazy var sharesCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "share-count"), for: .normal)
        return button
    }()
    
    lazy var commentsCountLabel = self.createDescriptionLabel()
    lazy var commentsCountButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "comment-count"), for: .normal)
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
        contentView.addSubview(voteActionsContainerView)
        voteActionsContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        voteActionsContainerView.addSubview(upVoteButton)
        voteActionsContainerView.addSubview(likeCountLabel)
        voteActionsContainerView.addSubview(downVoteButton)
        
        upVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        downVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        likeCountLabel.autoPinEdge(.leading, to: .trailing, of: upVoteButton)
        likeCountLabel.autoPinEdge(.trailing, to: .leading, of: downVoteButton)
        
        likeCountLabel.autoPinEdge(toSuperviewEdge: .top)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .bottom)
        
        // comments and shares
        contentView.addSubview(sharesCountButton)
        sharesCountButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sharesCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteActionsContainerView)
        contentView.addSubview(commentsCountLabel)
        commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: sharesCountButton, withOffset: -23)
        commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteActionsContainerView)
        contentView.addSubview(commentsCountButton)
        commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: -8)
        commentsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteActionsContainerView)
        
        // separator
        let separatorView = UIView(height: 10)
        separatorView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        contentView.addSubview(separatorView)
        separatorView.autoPinEdge(.top, to: .bottom, of: voteActionsContainerView, withOffset: 16)
        separatorView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // layout content
        layoutContent()
    }
    
    func layoutContent() {
        fatalError("must override")
    }
    
    // MARK: - Methods
    override func observe() {
        super.observe()
        observePostChange()
    }
    
    func setUp(with post: ResponseAPIContentGetPost?) {
        guard let post = post else {return}
        self.post = post
        metaView.setUp(post: post)
        
        // Handle button
        self.upVoteButton.tintColor         = post.votes.hasUpVote ?? false ? .appMainColor: .lightGray
        self.likeCountLabel.text            =   "\((post.votes.upCount ?? 0) - (post.votes.downCount ?? 0))"
        self.downVoteButton.tintColor       = post.votes.hasDownVote ?? false ? .appMainColor: .lightGray
        
        // comments // shares count
        self.commentsCountLabel.text        =   "\(post.stats?.commentsCount ?? 0)"
        #warning("change this number later")
        self.sharesCountLabel.text         =   "\(post.stats?.viewCount ?? 0)"
        
    }
}
