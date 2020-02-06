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
    
    lazy var stateButton: UIView = {
        let view = UIView(height: 30, backgroundColor: .appMainColor, cornerRadius: 30 / 2)
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "icon-post-state-default")
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 20/18.95)
            .isActive = true
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 4.74, left: 5, bottom: 4.74, right: 0), excludingEdge: .trailing)
        
        view.addSubview(stateButtonLabel)
        stateButtonLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 5)
        stateButtonLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        stateButtonLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 5)
        stateButtonLabel.setContentHuggingPriority(.required, for: .horizontal)
        stateButtonLabel.adjustsFontSizeToFitWidth = true
        
        view.isUserInteractionEnabled = true
        view.tag = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateButtonTapped(_:))))
        
        return view
    }()
    
    lazy var stateButtonLabel = UILabel.with(textSize: 12, weight: .medium, textColor: .white)
    
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
        let actionButtonsStackView = UIStackView(axis: .horizontal, spacing: 0)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fillProportionally

        actionButtonsStackView.addArrangedSubviews([stateButton, moreActionButton])
        stateButton.widthAnchor.constraint(lessThanOrEqualToConstant: .adaptive(width: 208))
            .isActive = true
        
        contentView.addSubview(actionButtonsStackView)
        actionButtonsStackView.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 21.0), xInset: CGFloat.adaptive(width: 4.0))

        metaView.autoPinEdge(.trailing, to: .leading, of: actionButtonsStackView, withOffset: 4)

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
        stateButton.isHidden = true
        if let mosaic = post.mosaic {
            set(mosaic: mosaic)
        }
    }

    private func set(mosaic: ResponseAPIRewardsGetStateBulkMosaic) {
        guard mosaic.topCount > 0, let rewardString = mosaic.reward.components(separatedBy: " ").first, let rewardDouble = Double(rewardString), rewardDouble > 0 else {
            return
        }
        
        let isRewardState = mosaic.isClosed
        stateButton.isHidden = false
        stateButtonLabel.text = isRewardState ? rewardDouble.currencyValueFormatted : "top".localized().uppercaseFirst
        stateButton.tag = Int(isRewardState.int)
    }
}
