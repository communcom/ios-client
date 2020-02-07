//
//  PostTitleView.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import SwiftTheme

class PostMetaView: MyView {
    // MARK: - Enums
    class TapGesture: UITapGestureRecognizer {
        var post: ResponseAPIContentGetPost!
    }
    
    // MARK: - Properties
    var stackViewTrailingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?

    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 40)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 3, alignment: .leading)
    lazy var comunityNameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var subtitleLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .a5a7bd)
    lazy var stateButtonLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .white)

    lazy var stateButton: UIView = {
        let view = UIView(height: 30, backgroundColor: .appMainColor, cornerRadius: 30 / 2)
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "icon-post-state-default")
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 20/18.95)
            .isActive = true
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0), excludingEdge: .trailing)
        
        view.addSubview(stateButtonLabel)
        stateButtonLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 5)
        stateButtonLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        stateButtonLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        stateButtonLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        view.isUserInteractionEnabled = true
        view.tag = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateButtonTapped(_:))))
        
        view.widthAnchor.constraint(lessThanOrEqualToConstant: .adaptive(width: 208.0)).isActive = true
        
        return view
    }()

    // MARK: - Properties
    var isUserNameTappable = true
    var isCommunityNameTappable = true

    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        
        // avatar
        addSubview(avatarImageView)
        avatarImageView.autoPinTopAndLeadingToSuperView()
        
        addSubview(stackView)
        stackView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        stackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        stackView.addArrangedSubview(comunityNameLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        avatarImageView.setAvatar(urlString: post.community?.avatarUrl, namePlaceHolder: post.community?.name ?? "C")
        comunityNameLabel.text = post.community?.name
        subtitleLabel.attributedText = NSMutableAttributedString()
            .text(Date.timeAgo(string: post.meta.creationTime) + " • ", size: 12, weight: .semibold, color: .a5a7bd)
            .text(post.author?.username ?? post.author?.userId ?? "", size: 12, weight: .semibold, color: .appMainColor)
        
        // add gesture
        if isUserNameTappable {
            let tap = TapGesture(target: self, action: #selector(userNameTapped(_:)))
            tap.post = post
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.addGestureRecognizer(tap)
        }
        
        if isCommunityNameTappable {
            let tapLabel = TapGesture(target: self, action: #selector(communityNameTapped(_:)))
            let tapAvatar = TapGesture(target: self, action: #selector(communityNameTapped(_:)))
            tapLabel.post = post
            tapAvatar.post = post

            avatarImageView.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(tapAvatar)
            comunityNameLabel.isUserInteractionEnabled = true
            comunityNameLabel.addGestureRecognizer(tapLabel)
        }
        
        setMosaic(post.mosaic)
    }
    
    private func setMosaic(_ mosaic: ResponseAPIRewardsGetStateBulkMosaic?) {
        // clean
        stateButton.removeFromSuperview()
        stackViewTrailingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        trailingConstraint = nil
        
        guard let mosaicItem = mosaic, mosaicItem.topCount > 0, let rewardString = mosaicItem.reward.components(separatedBy: " ").first, let rewardDouble = Double(rewardString), rewardDouble > 0 else {
            stackViewTrailingConstraint = stackView.autoPinEdge(toSuperviewEdge: .trailing)
            stackViewTrailingConstraint?.isActive = true
            return
        }
        
        addSubview(stateButton)
        stateButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        stackViewTrailingConstraint = stackView.autoPinEdge(.trailing, to: .leading, of: stateButton, withOffset: -4)
        stackViewTrailingConstraint?.isActive = true
        
        trailingConstraint = stateButton.autoPinEdge(toSuperviewEdge: .trailing)
        trailingConstraint?.isActive = true
        
        let isRewardState = mosaicItem.isClosed
        stateButtonLabel.text = isRewardState ? rewardDouble.currencyValueFormatted : "top".localized().uppercaseFirst
        stateButton.tag = Int(isRewardState.int)
    }
    
    // MARK: - Actions
    @objc func userNameTapped(_ sender: TapGesture) {
        guard let userId = sender.post.author?.userId else {return}
        parentViewController?.showProfileWithUserId(userId)
    }
    
    @objc func communityNameTapped(_ sender: TapGesture) {
        guard let communityId = sender.post.community?.communityId else {return}
        parentViewController?.showCommunityWithCommunityId(communityId)
    }
    
    @objc func stateButtonTapped(_ gesture: UITapGestureRecognizer) {
        let postLink = "https://commun.com/faq?#What%20else%20can%20you%20do%20with%20the%20points?"
        let userNameRulesView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 355.0), height: .adaptive(height: 193.0))), andParameters: gesture.view?.tag == 0 ? .topState : .rewardState)
        
        let cardVC = CardViewController(contentView: userNameRulesView)
        parentViewController?.present(cardVC, animated: true, completion: nil)
        
        userNameRulesView.completionDismissWithAction = { value in
            self.parentViewController?.dismiss(animated: true, completion: {
                if value, let baseVC = self.parentViewController as? BaseViewController {
                    baseVC.load(url: postLink)
                }
            })
        }
    }
}
