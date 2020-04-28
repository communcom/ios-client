//
//  PostStatsView.swift
//  Commun
//
//  Created by Chung Tran on 2/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol PostStatsViewDelegate: class {
    func postStatsView(_ postStatsView: PostStatsView, didTapOnDonationCountLabel donationCountLabel: UIView)
    func postStatsView(_ postStatsView: PostStatsView, didTapOnLikeCountLabel likeCountLabel: UIView)
}

class PostStatsView: MyView {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    weak var delegate: PostStatsViewDelegate?
    
    // MARK: - Subviews
    lazy var voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    lazy var plusLabel = UILabel.with(text: "+", textSize: 17, weight: .semibold, textColor: .appMainColor)
    lazy var donationCountLabel = UILabel.with(numberOfLines: 2)
    
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
        UILabel.with(textSize: .adaptive(width: 12.0), weight: .medium, textColor: .appGrayColor, numberOfLines: 1)
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(voteContainerView)
        voteContainerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        addSubview(plusLabel)
        plusLabel.autoPinEdge(.leading, to: .trailing, of: voteContainerView, withOffset: 6)
        plusLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(donationCountLabel)
        donationCountLabel.autoPinEdge(.leading, to: .trailing, of: plusLabel, withOffset: 4)
        donationCountLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
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
        
        donationCountLabel.isUserInteractionEnabled = true
        plusLabel.isUserInteractionEnabled = true
        donationCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donationCountLabelDidTouch)))
        plusLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donationCountLabelDidTouch)))
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        voteContainerView.setUp(with: post.votes, userID: post.author?.userId)
        
        // Donation
        if let donationCount = post.donationCount {
            donationCountLabel.isHidden = false
            plusLabel.isHidden = false
            donationCountLabel.attributedText = NSMutableAttributedString()
                .text("\(donationCount.kmFormatted)", size: 14, weight: .bold, color: .appMainColor)
                .text("\n")
                .text("points".localized(), size: 14, weight: .medium, color: .appMainColor)
                .withParagraphStyle(minimumLineHeight: 12)
        } else {
            donationCountLabel.isHidden = true
            plusLabel.isHidden = true
        }
        
        // Comments count
        self.commentsCountLabel.text = "\(post.stats?.commentsCount ?? 0)"
        
        // Views count
        self.viewsCountLabel.text = "\(post.viewsCount ?? 0)"
        
        // Shares count
        //        self.sharesCountLabel.text = "\(post.viewsCount ?? 0)"
    }
    
    func fillShareCountButton(_ fill: Bool = true) {
        shareButton.setImage(UIImage(named: fill ? "share-count-fill" : "share-count"), for: .normal)
    }
    
    func fillCommentCountButton(_ fill: Bool = true) {
        commentsCountButton.setImage(UIImage(named: fill ? "comment-count-fill" : "comment-count"), for: .normal)
        commentsCountLabel.textColor = fill ? .appMainColor : .appGrayColor
    }
    
    @objc func donationCountLabelDidTouch() {
        delegate?.postStatsView(self, didTapOnDonationCountLabel: donationCountLabel)
    }
}
