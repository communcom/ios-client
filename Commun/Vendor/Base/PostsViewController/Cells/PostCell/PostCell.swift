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
    weak var delegate: PostCellDelegate?
    
    // MARK: - Subviews
    lazy var topView = UIView(height: 0, backgroundColor: .f3f5fa)
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var moreActionButton: UIButton = {
        let moreActionButtonInstance = UIButton(width: .adaptive(width: 40.0), height: .adaptive(width: 40.0))
        moreActionButtonInstance.tintColor = .appGrayColor
        moreActionButtonInstance.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        moreActionButtonInstance.addTarget(self, action: #selector(moreActionsButtonTapped), for: .touchUpInside)
        
        return moreActionButtonInstance
    }()
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())

    lazy var bottomView = UIView(height: 10, backgroundColor: .f3f5fa)
    
    // MARK: - Layout
    override func setUpViews() {
        super.setUpViews()
        
        selectionStyle = .none
        
        // Top view
        contentView.addSubview(topView)
        topView.autoPinEdge(toSuperviewEdge: .top)
        topView.autoPinEdge(toSuperviewEdge: .leading)
        topView.autoPinEdge(toSuperviewEdge: .trailing)
        
        // Meta view
        contentView.addSubview(metaView)
        metaView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: .adaptive(height: 16))
        metaView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16))

        // moreAction buttons
        contentView.addSubview(moreActionButton)
        moreActionButton.autoPinEdge(.top, to: .bottom, of: topView, withOffset: .adaptive(height: 16))
        moreActionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 4))
        
        metaView.autoPinEdge(.trailing, to: .leading, of: moreActionButton, withOffset: .adaptive(width: 4.0))
        
        // postStatsView
        contentView.addSubview(postStatsView)
        postStatsView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16))
        postStatsView.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 16))

        // separator
        contentView.addSubview(bottomView)
        bottomView.autoPinEdge(.top, to: .bottom, of: postStatsView, withOffset: 10)
        bottomView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // layout content
        layoutContent()
        
        // action
        postStatsView.shareButton.addTarget(self, action: #selector(shareButtonTapped(button:)), for: .touchUpInside)
        postStatsView.voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonTapped(button:)), for: .touchUpInside)
        postStatsView.voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonTapped(button:)), for: .touchUpInside)
        postStatsView.commentsCountButton.addTarget(self, action: #selector(commentCountsButtonDidTouch), for: .touchUpInside)
    }
    
    func layoutContent() {
        fatalError("must override")
    }
    
    // MARK: - Methods
    func setUp(with post: ResponseAPIContentGetPost) {
        self.post = post
        metaView.setUp(post: post)
        postStatsView.setUp(with: post)
    }
}
