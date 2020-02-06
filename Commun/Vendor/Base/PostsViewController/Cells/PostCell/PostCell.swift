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
        UILabel.with(textSize: CGFloat.adaptive(width: 12.0), weight: .medium, textColor: #colorLiteral(red: 0.6470588235, green: 0.6549019608, blue: 0.7411764706, alpha: 1), numberOfLines: 1)
    }
    
    lazy var metaView = PostMetaView(height: 40)

    lazy var stateActionButton: UIButton = {
        let stateActionButtonInstance = UIButton(width: CGFloat.adaptive(width: 208.0),
                                                 height: CGFloat.adaptive(height: 30.0),
                                                 label: "".localized().uppercaseFirst,
                                                 labelFont: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 12.0), weight: .semibold),
                                                 backgroundColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1),
                                                 textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                                 cornerRadius: CGFloat.adaptive(height: 30.0) / 2,
                                                 contentInsets: nil)
        
        stateActionButtonInstance.setImage(UIImage(named: "icon-post-state-default"), for: .normal)
        
        stateActionButtonInstance.contentEdgeInsets = UIEdgeInsets(top: CGFloat.adaptive(height: 5.0),
                                                                   left: CGFloat.adaptive(width: 5.0),
                                                                   bottom: CGFloat.adaptive(height: 5.0),
                                                                   right: CGFloat.adaptive(width: 5.0))
        
        stateActionButtonInstance.titleEdgeInsets = UIEdgeInsets(top: CGFloat.adaptive(height: 0.0),
                                                                 left: CGFloat.adaptive(width: 5.0),
                                                                 bottom: CGFloat.adaptive(height: 0.0),
                                                                 right: CGFloat.adaptive(width: 0.0))
        
        stateActionButtonInstance.addTarget(self, action: #selector(stateButtonTapped), for: .touchUpInside)
        stateActionButtonInstance.tag = 0
        stateActionButtonInstance.contentHorizontalAlignment = .leading
        stateActionButtonInstance.translatesAutoresizingMaskIntoConstraints = false
        
        return stateActionButtonInstance
    }()

    var stateActionButtonWidthConstraint: NSLayoutConstraint?
    
    lazy var moreActionButton: UIButton = {
        let moreActionButtonInstance = UIButton(width: CGFloat.adaptive(width: 40.0), height: CGFloat.adaptive(width: 40.0))
        moreActionButtonInstance.tintColor = .appGrayColor
        moreActionButtonInstance.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
        moreActionButtonInstance.addTarget(self, action: #selector(menuButtonTapped(button:)), for: .touchUpInside)
        
        return moreActionButtonInstance
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
        metaView.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 16.0))
        metaView.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(width: 16.0))

        // state & moreAction buttons
        let actionButtonsStackView = UIStackView(axis: .horizontal, spacing: CGFloat.adaptive(width: 0.0))
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fillProportionally

        actionButtonsStackView.addArrangedSubviews([stateActionButton, moreActionButton])
        stateActionButtonWidthConstraint = stateActionButton.widthAnchor.constraint(equalToConstant: CGFloat.adaptive(width: 208.0))
        stateActionButtonWidthConstraint!.isActive = true
        
        contentView.addSubview(actionButtonsStackView)
        actionButtonsStackView.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 21.0), xInset: CGFloat.adaptive(width: 4.0))

        metaView.autoPinEdge(.trailing, to: .leading, of: actionButtonsStackView, withOffset: CGFloat.adaptive(width: 0.0))

        // action buttons
        contentView.addSubview(voteContainerView)
        voteContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(width: 16.0))

        voteContainerView.upVoteButton.addTarget(self, action: #selector(upVoteButtonTapped(button:)), for: .touchUpInside)
        voteContainerView.downVoteButton.addTarget(self, action: #selector(downVoteButtonTapped(button:)), for: .touchUpInside)

        // Shares
        contentView.addSubview(shareButton)
        shareButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: CGFloat.adaptive(width: 16.0))
        shareButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)

        // Comments
        contentView.addSubview(commentsCountLabel)
        commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: shareButton, withOffset: CGFloat.adaptive(width: -23.0))
        commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
       
        contentView.addSubview(commentsCountButton)
        commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: CGFloat.adaptive(width: -8.0))
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
        let separatorView = UIView(height: CGFloat.adaptive(height: 10.0))
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

        stateActionButton.isHidden = true
        metaView.setUp(post: post)
        voteContainerView.setUp(with: post.votes, userID: post.author?.userId)

        // Comments count
        self.commentsCountLabel.text = "\(post.stats?.commentsCount ?? 0)"

        // Views count
        self.viewsCountLabel.text = "\(post.stats?.viewCount ?? 0)"

        // Shares count
        // TODO: change this number later
        self.sharesCountLabel.text = "\(post.stats?.viewCount ?? 0)"
        
        // State action button: set value & button width
        if let mosaic = post.mosaic {
            set(mosaic: mosaic)
        }
    }

    private func set(mosaic: ResponseAPIRewardsGetStateBulkMosaic) {
        guard mosaic.topCount > 0, let rewardString = mosaic.reward.components(separatedBy: " ").first, let rewardDouble = Double(rewardString), rewardDouble > 0 else {
            return
        }
        
        let isRewardState = mosaic.isClosed
        stateActionButton.isHidden = false
        stateActionButton.setTitle(isRewardState ? rewardDouble.currencyValueFormatted : "top".localized().uppercaseFirst, for: .normal)
        stateActionButton.tag = Int(isRewardState.int)
        stateActionButton.sizeToFit()
        
        let width = stateActionButton.intrinsicContentSize.width + 10.0
        stateActionButtonWidthConstraint?.constant = width
    }
}
