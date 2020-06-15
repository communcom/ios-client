//
//  PostHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol PostHeaderViewDelegate: class {
    func headerViewUpVoteButtonDidTouch(_ headerView: PostHeaderView)
    func headerViewDownVoteButtonDidTouch(_ headerView: PostHeaderView)
    func headerViewShareButtonDidTouch(_ headerView: PostHeaderView)
    func headerViewCommentButtonDidTouch(_ headerView: PostHeaderView)
    func headerViewDonationButtonDidTouch(_ headerView: PostHeaderView, amount: Double?)
    func headerViewDonationViewCloseButtonDidTouch(_ donationView: CMMessageView)
    func headerView(_ headerView: PostHeaderView, donationUsersViewDidTouch donationUsersView: DonationUsersView)
}

class PostHeaderView: MyTableHeaderView {
    var voteContainerView: VoteContainerView { postStatsView.voteContainerView }
    
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    weak var delegate: PostHeaderViewDelegate?

    // MARK: - Subviews
    lazy var titleLabel = UILabel.with(text: "", textSize: 21, weight: .bold, numberOfLines: 0)
    
    lazy var contentTextView = PostHeaderTextView(forExpandable: ())
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())
    
    lazy var donationUsersView = DonationUsersView()
    
    lazy var donationView = DonationView()
    
//    lazy var sortButton = RightAlignedIconButton(imageName: "small-down-arrow", label: "interesting first".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor, contentInsets: UIEdgeInsets(horizontal: 8, vertical: 0))
    
    // MARK: - Constraints
    var contentTextViewTopConstraint: NSLayoutConstraint?
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(contentTextView)
        contentTextViewTopConstraint = contentTextView.autoPinEdge(toSuperviewEdge: .top)
        contentTextView.autoPinEdge(toSuperviewEdge: .leading)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing)
        contentTextView.delegate = self
        
        addSubview(postStatsView)
        postStatsView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 10)
        postStatsView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16))
        postStatsView.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 16))
        
        postStatsView.voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch(_:)), for: .touchUpInside)
        postStatsView.voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch(_:)), for: .touchUpInside)
        postStatsView.shareButton.addTarget(self, action: #selector(shareButtonDidTouch(_:)), for: .touchUpInside)
        
        postStatsView.commentsCountButton.addTarget(self, action: #selector(commentsCountButtonDidTouch), for: .touchUpInside)
        
        let commentsLabel = UILabel.with(text: "comments".localized().uppercaseFirst, textSize: 21, weight: .bold)
        addSubview(commentsLabel)
        commentsLabel.autoPinEdge(.top, to: .bottom, of: postStatsView, withOffset: 20)
        commentsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
//        addSubview(sortButton)
//        sortButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
//        sortButton.autoAlignAxis(.horizontal, toSameAxisOf: commentsLabel)
        
        // Pin bottom
        commentsLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        // donation
        addSubview(donationUsersView)
        donationUsersView.autoAlignAxis(toSuperviewAxis: .vertical)
        donationUsersView.autoPinEdge(.bottom, to: .top, of: postStatsView, withOffset: -4)
        donationUsersView.senderView = postStatsView.donationCountLabel
        donationUsersView.delegate = self
        
        donationUsersView.isUserInteractionEnabled = true
        donationUsersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donationUsersViewDidTouch)))
        
        // donation buttons
        addSubview(donationView)
        donationView.autoAlignAxis(toSuperviewAxis: .vertical)
        donationView.autoPinEdge(.bottom, to: .top, of: postStatsView, withOffset: -4)
        donationView.senderView = postStatsView.voteContainerView.likeCountLabel
        donationView.delegate = self
        
        for (i, button) in donationView.amountButtons.enumerated() {
            button.tag = i
            button.addTarget(self, action: #selector(donationAmountDidTouch(sender:)), for: .touchUpInside)
        }
        donationView.otherButton.tag = donationView.amountButtons.count
        donationView.otherButton.addTarget(self, action: #selector(donationAmountDidTouch(sender:)), for: .touchUpInside)
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        titleLabel.removeFromSuperview()
        contentTextViewTopConstraint?.isActive = false
        
        if post.document?.attributes?.type == "article" {
            // Show title
            titleLabel.text = post.document?.attributes?.title
            
            addSubview(titleLabel)
            titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .bottom)
            
            contentTextViewTopConstraint = contentTextView.autoPinEdge(.top, to: .bottom, of: titleLabel)
            contentTextViewTopConstraint?.isActive = true

        } else {
            titleLabel.text = nil
            
            contentTextViewTopConstraint = contentTextView.autoPinEdge(toSuperviewEdge: .top)
            contentTextViewTopConstraint?.isActive = true
        }
        
        postStatsView.setUp(with: post)
        
        // Show content & Parse data
        if let attributedString = post.document?.toAttributedString(
            currentAttributes: contentTextView.defaultAttributes,
            attachmentSize: contentTextView.attachmentSize,
            attachmentType: PostPageTextAttachment.self)
        {
            let aStr = NSMutableAttributedString(attributedString: attributedString)
            if aStr.string.ends(with: "\r") {
                aStr.deleteCharacters(in: NSRange(location: aStr.length - 1, length: 1))
            }
            contentTextView.attributedText = aStr
        } else {
            contentTextView.attributedText = nil
        }
        
        // donations
        donationUsersView.isHidden = true
        if post.showDonator == true,
            post.showDonationButtons != true,
            let donations = post.donations?.donations
        {
            donationUsersView.isHidden = false
            donationUsersView.setUp(with: donations)
        }
        
        donationView.isHidden = true
        if post.showDonationButtons == true,
            post.author?.userId != Config.currentUser?.id
        {
            donationView.isHidden = false
        }
        
        layoutSubviews()
    }
    
    // MARK: - Actions
    @objc func upVoteButtonDidTouch(_ sender: Any) {
        voteContainerView.animateUpVote {
            self.delegate?.headerViewUpVoteButtonDidTouch(self)
        }
    }
    
    @objc func downVoteButtonDidTouch(_ sender: Any) {
        voteContainerView.animateDownVote {
            self.delegate?.headerViewDownVoteButtonDidTouch(self)
        }
    }
    
    @objc func shareButtonDidTouch(_ sender: Any) {
        delegate?.headerViewShareButtonDidTouch(self)
    }
    
    @objc func commentsCountButtonDidTouch() {
        delegate?.headerViewCommentButtonDidTouch(self)
    }
}

extension PostHeaderView: DonationUsersViewDelegate, DonationViewDelegate {
    @objc func donationUsersViewDidTouch() {
        delegate?.headerView(self, donationUsersViewDidTouch: donationUsersView)
    }
    
    @objc func donationAmountDidTouch(sender: UIButton) {
        let amount = donationView.amounts[safe: sender.tag]?.double
        delegate?.headerViewDonationButtonDidTouch(self, amount: amount)
    }
    
    func donationUsersViewCloseButtonDidTouch(_ donationUserView: DonationUsersView) {
        delegate?.headerViewDonationViewCloseButtonDidTouch(donationUserView)
    }
    func donationViewCloseButtonDidTouch(_ donationView: DonationView) {
        delegate?.headerViewDonationViewCloseButtonDidTouch(donationView)
    }
}
