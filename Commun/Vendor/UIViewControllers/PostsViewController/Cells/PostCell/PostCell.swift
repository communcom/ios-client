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
    lazy var topView = UIView(backgroundColor: .appLightGrayColor)
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var moreActionButton: UIButton = {
        let moreActionButtonInstance = UIButton(width: .adaptive(width: 40.0), height: .adaptive(width: 40.0))
        moreActionButtonInstance.tintColor = .appGrayColor
        moreActionButtonInstance.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        moreActionButtonInstance.addTarget(self, action: #selector(moreActionsButtonTapped), for: .touchUpInside)
        
        return moreActionButtonInstance
    }()
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())

    lazy var bottomView = UIView(backgroundColor: .appLightGrayColor)
    
    lazy var donationUsersView = DonationUsersView()
    
    // MARK: - Layout
    override func prepareForReuse() {
        super.prepareForReuse()
        donationUsersView.removeFromSuperview()
    }
    
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
        postStatsView.delegate = self
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
        guard let ex = explanation,
            ex != .hidden,
            ExplanationView.shouldShowViewWithId(ex.rawValue)
        else {
            if self.topViewHeightConstraint?.isActive != true {
                self.topView.removeAllExplanationViews()
                self.topViewHeightConstraint?.isActive = true
            }
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
            label = "wow, this post will be rewarded!".localized().uppercaseFirst
            senderView = metaView.stateButton
        default:
            return
        }
        
        let eView = ExplanationView(id: ex.rawValue, title: title, descriptionText: label, imageName: "explanation-\(ex.rawValue)", senderView: senderView, showAbove: true)
        
        topView.addSubview(eView)
        eView.fixArrowView()
        eView.autoPinEdge(toSuperviewEdge: .top)
        eView.autoPinEdge(toSuperviewEdge: .bottom)
        eView.autoPinEdge(toSuperviewEdge: .leading)
        eView.autoPinEdge(toSuperviewEdge: .trailing)
        
        eView.closeDidTouch = {
            var post = self.post
            post?.topExplanation = .hidden
            post?.notifyChanged()
        }
    }
    
    private func setBottomViewWithExplanation(_ explanation: ResponseAPIContentGetPost.BottomExplanationType?)
    {
        guard let ex = explanation,
            ex != .hidden,
            ExplanationView.shouldShowViewWithId(ex.rawValue)
        else {
            postStatsView.fillShareCountButton(false)
            postStatsView.fillCommentCountButton(false)
            postStatsView.voteContainerView.fill(false)
            if self.bottomViewHeigthConstraint?.isActive != true {
                self.bottomView.removeAllExplanationViews()
                self.bottomViewHeigthConstraint?.isActive = true
            }
            return
        }
        
        bottomView.removeAllExplanationViews()
        bottomViewHeigthConstraint?.isActive = false
        
        let title: String
        let label: String
        let senderView: UIView
        switch ex {
        case .shareYourPost:
            title = "share your post".localized().uppercaseFirst
            label = "great, your post is successfully published".localized().uppercaseFirst
            senderView = postStatsView.shareButton
            postStatsView.fillShareCountButton()
        case .rewardsForLikes:
            title = "rewards for like".localized().uppercaseFirst
            label = "yes, you get rewards for likes as well".localized().uppercaseFirst
            senderView = postStatsView.voteContainerView
            postStatsView.voteContainerView.fill()
        case .rewardsForComments:
            title = "rewards for comment".localized().uppercaseFirst
            label = "comments get rewards too".localized().uppercaseFirst
            senderView = postStatsView.commentsCountButton
            postStatsView.fillCommentCountButton()
        default:
            return
        }
        
        let eView = ExplanationView(id: ex.rawValue, title: title, descriptionText: label, imageName: "explanation-\(ex.rawValue)", senderView: senderView, showAbove: false)
        
        bottomView.addSubview(eView)
        eView.fixArrowView()
        eView.autoPinEdge(toSuperviewEdge: .top)
        eView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        eView.autoPinEdge(toSuperviewEdge: .leading)
        eView.autoPinEdge(toSuperviewEdge: .trailing)
        
        eView.closeDidTouch = {
            var post = self.post
            post?.bottomExplanation = .hidden
            post?.notifyChanged()
        }
    }
}

extension PostCell: PostStatsViewDelegate {
    func postStatsView(_ postStatsView: PostStatsView, didTapOnDonationCountLabel donationCountLabel: UIView) {
        // TODO: - show donations
        donationUsersView.removeFromSuperview()
        addSubview(donationUsersView)
        donationUsersView.autoSetDimension(.width, toSize: 200)
        donationUsersView.autoAlignAxis(toSuperviewAxis: .vertical)
        donationUsersView.autoPinEdge(.bottom, to: .top, of: postStatsView, withOffset: -4)
        
        donationUsersView.senderView = donationCountLabel
    }
}
