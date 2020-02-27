//
//  PostStatsView.swift
//  Commun
//
//  Created by Chung Tran on 2/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class PostStatsView: MyView {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Subviews
    lazy var voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    lazy var sharesCountLabel = self.createDescriptionLabel()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "share-count"), for: .normal)
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
    
    // MARK: - Methods
    private func createDescriptionLabel() -> UILabel {
        UILabel.with(textSize: .adaptive(width: 12.0), weight: .medium, textColor: #colorLiteral(red: 0.6470588235, green: 0.6549019608, blue: 0.7411764706, alpha: 1), numberOfLines: 1)
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(voteContainerView)
        voteContainerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        // Shares
        addSubview(shareButton)
        shareButton.autoPinEdge(toSuperviewEdge: .trailing)
        shareButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        // Comments
        addSubview(commentsCountLabel)
        commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: shareButton, withOffset: .adaptive(width: -23.0))
        commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        addSubview(commentsCountButton)
        commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: .adaptive(width: -8.0))
        commentsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        // Views
        addSubview(viewsCountLabel)
        viewsCountLabel.autoPinEdge(.trailing, to: .leading, of: commentsCountButton, withOffset: .adaptive(width: -23))
        viewsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        addSubview(viewsCountButton)
        viewsCountButton.autoPinEdge(.trailing, to: .leading, of: viewsCountLabel, withOffset: .adaptive(width: -8))
        viewsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
        
        viewsCountButton.isUserInteractionEnabled = false
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        voteContainerView.setUp(with: post.votes, userID: post.author?.userId)
        
        // Comments count
        self.commentsCountLabel.text = "\(post.stats?.commentsCount ?? 0)"
        
        // Views count
        self.viewsCountLabel.text = "\(post.viewsCount ?? 0)"
        
        // Shares count
        //        self.sharesCountLabel.text = "\(post.viewsCount ?? 0)"
    }
}
