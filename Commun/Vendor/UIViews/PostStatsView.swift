//
//  PostStatsView.swift
//  Commun
//
//  Created by Chung Tran on 2/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol PostStatsViewDelegate: class {
    var post: ResponseAPIContentGetPost? {get}
    func postStatsViewDonationButtonDidTouch(_ postStatsView: PostStatsView)
    func postStatsViewDonatorsDidTouch(_ postStatsView: PostStatsView)
}

extension PostStatsViewDelegate {
    func postStatsViewDonationButtonDidTouch(_ postStatsView: PostStatsView) {
        var post = self.post
        post?.showDonationButtons = true
        post?.notifyChanged()
    }
    
    func postStatsViewDonatorsDidTouch(_ postStatsView: PostStatsView) {
        guard let viewController = (self as? UIViewController) ?? (self as? UIView)?.parentViewController
        else {return}
        
        guard let donations = post?.donations else {return}
        let vc = DonationsVC(donations: donations)
        vc.modelSelected = {donation in
            vc.dismiss(animated: true) {
                viewController.showProfileWithUserId(donation.sender.userId)
            }
        }
        
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = vc
        viewController.present(navigation, animated: true, completion: nil)
    }
}

class PostStatsView: MyView {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    weak var delegate: PostStatsViewDelegate?
    
    // MARK: - Subviews
    lazy var voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    lazy var sharesCountLabel = self.createDescriptionLabel()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(width: 20, height: 18)
        button.setImage(UIImage(named: "share-count"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -11, left: -13, bottom: -11, right: -13)
        
        return button
    }()
    lazy var thumbUpLabel = UILabel(width: 30, height: 30, backgroundColor: .appLightGrayColor, cornerRadius: 15)
    lazy var donatorsLabel = UILabel.with(textSize: 14, weight: .medium, textColor: .appGrayColor, numberOfLines: 0)
    lazy var donateButton = UIButton(label: "donate".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 14), textColor: .appMainColor)
    
    lazy var donationsView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        thumbUpLabel.textAlignment = .center
        thumbUpLabel.font = .systemFont(ofSize: 12)
        thumbUpLabel.text = "👍"
        thumbUpLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        thumbUpLabel.isUserInteractionEnabled = true
        thumbUpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donatorsLabelDidTouch)))
        
        donatorsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donatorsLabelDidTouch)))
        
        donateButton.addTarget(self, action: #selector(donateButtonDidTouch), for: .touchUpInside)
        donateButton.setContentHuggingPriority(.required, for: .horizontal)
        
        stackView.addArrangedSubviews([
            thumbUpLabel,
            donatorsLabel,
            donateButton
        ])
        
        return stackView
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
        let actionsViewWrapper: UIView = {
            let view = UIView(forAutoLayout: ())
            view.addSubview(voteContainerView)
            voteContainerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
            
            // Shares
            view.addSubview(shareButton)
            shareButton.autoPinEdge(toSuperviewEdge: .trailing)
            shareButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
            
            // Comments
            view.addSubview(commentsCountLabel)
            commentsCountLabel.autoPinEdge(.trailing, to: .leading, of: shareButton, withOffset: .adaptive(width: -23.0))
            commentsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
            
            view.addSubview(commentsCountButton)
            commentsCountButton.autoPinEdge(.trailing, to: .leading, of: commentsCountLabel, withOffset: .adaptive(width: -8.0))
            commentsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
            
            // Views
            view.addSubview(viewsCountLabel)
            viewsCountLabel.autoPinEdge(.trailing, to: .leading, of: commentsCountButton, withOffset: .adaptive(width: -23))
            viewsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
            
            view.addSubview(viewsCountButton)
            viewsCountButton.autoPinEdge(.trailing, to: .leading, of: viewsCountLabel, withOffset: .adaptive(width: -8))
            viewsCountButton.autoAlignAxis(.horizontal, toSameAxisOf: voteContainerView)
            return view
        }()
        
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        stackView.addArrangedSubviews([
            donationsView.padding(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)),
            .spacer(height: 2, backgroundColor: .appLightGrayColor),
            actionsViewWrapper.padding(UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
        ])
        
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
        
        // donations
        var donatorsText: String?
        if let donations = post.donations?.donations {
            let donators = Array(Set(donations.compactMap {$0.sender.representationName}))
            
            if donators.count <= 2 {
                donatorsText = donators.joined(separator: ", ")
            } else {
                donatorsText = Array(donators.prefix(2)).joined(separator: ", ") + "and".localized() + "\(donators.count - 2)" + " " + "others".localized()
            }
            thumbUpLabel.isUserInteractionEnabled = true
            donatorsLabel.isUserInteractionEnabled = true
        } else {
            donatorsText = "0"
            thumbUpLabel.isUserInteractionEnabled = false
            donatorsLabel.isUserInteractionEnabled = false
        }
        donatorsLabel.text = donatorsText
        
        donateButton.isHidden = post.author?.userId == Config.currentUser?.id
    }
    
    func fillShareCountButton(_ fill: Bool = true) {
        shareButton.setImage(UIImage(named: fill ? "share-count-fill" : "share-count"), for: .normal)
    }
    
    func fillCommentCountButton(_ fill: Bool = true) {
        commentsCountButton.setImage(UIImage(named: fill ? "comment-count-fill" : "comment-count"), for: .normal)
        commentsCountLabel.textColor = fill ? .appMainColor : .appGrayColor
    }
    
    @objc func donateButtonDidTouch() {
        delegate?.postStatsViewDonationButtonDidTouch(self)
    }
    
    @objc func donatorsLabelDidTouch() {
        delegate?.postStatsViewDonatorsDidTouch(self)
    }
}
