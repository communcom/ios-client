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
}

class PostHeaderView: MyTableHeaderView {
    var voteContainerView: VoteContainerView { postStatsView.voteContainerView }
    
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    weak var delegate: PostHeaderViewDelegate?

    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
    
    lazy var titleLabel = UILabel.with(text: "", textSize: 21, weight: .bold, numberOfLines: 0)
    
    lazy var contentTextView = PostHeaderTextView(forExpandable: ())
    
    lazy var postStatsView = PostStatsView(forAutoLayout: ())
    
    lazy var donationView = DonationView()
    
//    lazy var sortButton = RightAlignedIconButton(imageName: "small-down-arrow", label: "interesting first".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor, contentInsets: UIEdgeInsets(horizontal: 8, vertical: 0))
    
    // MARK: - Methods
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let spacer = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        let commentsLabel = UILabel.with(text: "comments".localized().uppercaseFirst, textSize: 21, weight: .bold)
        stackView.addArrangedSubviews([
            titleLabel,
            contentTextView,
            postStatsView,
            spacer,
            commentsLabel
        ])
        
        stackView.setCustomSpacing(10, after: contentTextView)
        stackView.setCustomSpacing(10, after: postStatsView)
        stackView.setCustomSpacing(16, after: spacer)
        
        titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        contentTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        postStatsView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        spacer.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        commentsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        
        contentTextView.delegate = self
        
        postStatsView.voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonDidTouch(_:)), for: .touchUpInside)
        postStatsView.voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonDidTouch(_:)), for: .touchUpInside)
        postStatsView.shareButton.addTarget(self, action: #selector(shareButtonDidTouch(_:)), for: .touchUpInside)
        
        postStatsView.commentsCountButton.addTarget(self, action: #selector(commentsCountButtonDidTouch), for: .touchUpInside)
        
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
        // Show title
        if let title = post.title, !title.trimmed.isEmpty {
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
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
        
        donationView.isHidden = true
        if post.showDonationButtons == true,
            post.author?.userId != Config.currentUser?.id
        {
            donationView.isHidden = false
        }
        
        setNeedsLayout()
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
