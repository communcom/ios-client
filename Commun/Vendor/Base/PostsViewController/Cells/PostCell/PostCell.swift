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
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var moreActionButton: UIButton = {
        let moreActionButtonInstance = UIButton(width: .adaptive(width: 40.0), height: .adaptive(width: 40.0))
        moreActionButtonInstance.tintColor = .appGrayColor
        moreActionButtonInstance.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        moreActionButtonInstance.addTarget(self, action: #selector(moreActionsButtonTapped), for: .touchUpInside)
        
        return moreActionButtonInstance
    }()
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())
    
    // MARK: - Layout
    override func setUpViews() {
        super.setUpViews()
        
        selectionStyle = .none
        
        // Meta view
        contentView.addSubview(metaView)
        metaView.autoPinEdge(toSuperviewEdge: .top, withInset: .adaptive(height: 16.0))
        metaView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16.0))

        // moreAction buttons
        contentView.addSubview(moreActionButton)
        moreActionButton.autoPinTopAndTrailingToSuperView(inset: .adaptive(height: 16.0), xInset: .adaptive(width: 4.0))
        metaView.autoPinEdge(.trailing, to: .leading, of: moreActionButton, withOffset: .adaptive(width: 4.0))
        
        // postStatsView
        contentView.addSubview(postStatsView)
        postStatsView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16))
        postStatsView.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 16))

        // separator
        let separatorView = UIView(height: .adaptive(height: 10.0))
        separatorView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        contentView.addSubview(separatorView)
        separatorView.autoPinEdge(.top, to: .bottom, of: postStatsView, withOffset: 10)
        separatorView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
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
