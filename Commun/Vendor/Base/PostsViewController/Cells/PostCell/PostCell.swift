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
    var topViewHeightConstraint: NSLayoutConstraint?
    var bottomViewHeigthConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var topView = UIView(backgroundColor: .f3f5fa)
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var moreActionButton: UIButton = {
        let moreActionButtonInstance = UIButton(width: .adaptive(width: 40.0), height: .adaptive(width: 40.0))
        moreActionButtonInstance.tintColor = .appGrayColor
        moreActionButtonInstance.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        moreActionButtonInstance.addTarget(self, action: #selector(moreActionsButtonTapped), for: .touchUpInside)
        
        return moreActionButtonInstance
    }()
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())

    lazy var bottomView = UIView(backgroundColor: .f3f5fa)
    
    // MARK: - Layout
    override func setUpViews() {
        super.setUpViews()
        
        selectionStyle = .none
        
        // Top view
        contentView.addSubview(topView)
        topView.autoPinEdge(toSuperviewEdge: .top)
        topView.autoPinEdge(toSuperviewEdge: .leading)
        topView.autoPinEdge(toSuperviewEdge: .trailing)
        
        topViewHeightConstraint = topView.autoSetDimension(.height, toSize: 0)
        
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
        
        bottomViewHeigthConstraint = bottomView.autoSetDimension(.height, toSize: 10)
        
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
        
        setTopViewWithExplanation(post.topExplanation)
        setBottomViewWithExplanation(post.bottomExplanation)
    }
    
    private func setTopViewWithExplanation(_ explanation: ResponseAPIContentGetPost.TopExplanationType?)
    {
        let failureHandler: () -> Void = {
            if self.topViewHeightConstraint?.isActive != true {
                self.topView.removeAllExplanationViews()
                self.topViewHeightConstraint?.isActive = true
            }
        }
        
        guard let ex = explanation else {
            failureHandler()
            return
        }
        
        topView.removeAllExplanationViews()
        topViewHeightConstraint?.isActive = false
        
        let title: String
        let label: String
        let senderView: UIView
        switch ex {
        case .reward:
            title = "what does it mean?".localized().uppercaseFirst
            label = "wow, this post will get the reward!\nDo you want to get rewards too? Create a post - it’s the best way to get them!".localized().uppercaseFirst
            senderView = metaView//.stateButton
        }
        
        let eView = ExplanationView(id: ex.rawValue, title: title, descriptionText: label, imageName: nil, senderView: senderView, showAbove: true)
        
        if !eView.shouldShow {
            failureHandler()
            return
        }
        
        topView.addSubview(eView)
        eView.fixArrowView()
        eView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        eView.autoPinEdge(toSuperviewEdge: .bottom)
        eView.autoPinEdge(toSuperviewEdge: .leading)
        eView.autoPinEdge(toSuperviewEdge: .trailing)
        
        eView.didRemoveFromSuperView = {
            self.post?.topExplanation = nil
            self.post?.notifyChanged()
        }
    }
    
    private func setBottomViewWithExplanation(_ explanation: ResponseAPIContentGetPost.BottomExplanationType?)
    {
        let failureHandler: () -> Void = {
            self.bottomView.removeAllExplanationViews()
            if self.bottomViewHeigthConstraint?.isActive != true {
                self.bottomViewHeigthConstraint?.isActive = true
            }
        }
        
        guard let explanation = explanation else {
            failureHandler()
            return
        }
        
        bottomView.removeAllExplanationViews()
        bottomViewHeigthConstraint?.isActive = false
        
        let title: String
        let label: String
        let senderView: UIView
        switch explanation {
        case .shareYourPost:
            title = "share your post".localized().uppercaseFirst
            label = "great, your post is successfully published!\nShare it with your friends to receive more rewards!".localized().uppercaseFirst
            senderView = postStatsView.shareButton
        case .rewardsForLikes:
            title = "rewards for like".localized().uppercaseFirst
            label = "yes, you get rewards for likes as well, and they have more value than you think!\nUpvoting or downvoting of posts decides if it’s going to be successful and receive the reward.".localized().uppercaseFirst
            senderView = postStatsView.voteContainerView
        case .rewardsForComments:
            title = "rewards for comment".localized().uppercaseFirst
            label = "wow, this post will get the reward!\nDo you want to get rewards too? Create a post - it’s the best way to get them!".localized().uppercaseFirst
            senderView = postStatsView.commentsCountButton
        }
        
        let eView = ExplanationView(id: explanation.rawValue, title: title, descriptionText: label, imageName: nil, senderView: senderView, showAbove: false)
        
        if !eView.shouldShow {
            failureHandler()
            return
        }
        
        bottomView.addSubview(eView)
        eView.fixArrowView()
        eView.autoPinEdge(toSuperviewEdge: .top)
        eView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        eView.autoPinEdge(toSuperviewEdge: .leading)
        eView.autoPinEdge(toSuperviewEdge: .trailing)
        
        eView.didRemoveFromSuperView = {
            self.post?.bottomExplanation = nil
            self.post?.notifyChanged()
        }
    }
}
