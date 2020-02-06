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

    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 40)
    lazy var comunityNameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var timeAgoLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .a5a7bd)
    lazy var byUserLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .appMainColor)
    lazy var stateButtonLabel = UILabel.with(textSize: 12, weight: .medium, textColor: .white)

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
        stateButtonLabel.adjustsFontSizeToFitWidth = true
        
        view.isUserInteractionEnabled = true
        view.tag = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateButtonTapped(_:))))
        
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
        
        // communityNameLabel
        addSubview(comunityNameLabel)
        comunityNameLabel.autoPinEdge(.top, to: .top, of: avatarImageView)
        comunityNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        comunityNameLabel.autoPinEdge(toSuperviewEdge: .trailing)
        comunityNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        addSubview(timeAgoLabel)
        timeAgoLabel.autoPinEdge(.top, to: .bottom, of: comunityNameLabel, withOffset: 3)
        timeAgoLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        // byUserLabel
        addSubview(byUserLabel)
        byUserLabel.autoPinEdge(.top, to: .bottom, of: comunityNameLabel, withOffset: 3)
        byUserLabel.autoPinEdge(.leading, to: .trailing, of: timeAgoLabel)
        byUserLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        byUserLabel.removeGestureRecognizers()
        
        comunityNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            .isActive = true
        byUserLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            .isActive = true
    }
    
    private func addMosaic() {
        addSubview(stateButton)
        stateButton.widthAnchor.constraint(lessThanOrEqualToConstant: .adaptive(width: 208.0)).isActive = true
        stateButton.autoPinTopAndTrailingToSuperView(inset: .adaptive(height: 5.0), xInset: .adaptive(width: 0.0))
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        avatarImageView.setAvatar(urlString: post.community?.avatarUrl, namePlaceHolder: post.community?.name ?? "C")
        comunityNameLabel.text = post.community?.name
        timeAgoLabel.text = Date.timeAgo(string: post.meta.creationTime) + " • "
        byUserLabel.text = post.author?.username ?? post.author?.userId
        
        // add gesture
        if isUserNameTappable {
            let tap = TapGesture(target: self, action: #selector(userNameTapped(_:)))
            tap.post = post
            byUserLabel.isUserInteractionEnabled = true
            byUserLabel.addGestureRecognizer(tap)
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
    }
    
    func set(mosaic: ResponseAPIRewardsGetStateBulkMosaic?) {
        guard let mosaicItem = mosaic, mosaicItem.topCount > 0, let rewardString = mosaicItem.reward.components(separatedBy: " ").first, let rewardDouble = Double(rewardString), rewardDouble > 0 else {
            return
        }
        
        let isRewardState = mosaicItem.isClosed
        stateButton.isHidden = false
        stateButtonLabel.text = isRewardState ? rewardDouble.currencyValueFormatted : "top".localized().uppercaseFirst
        stateButton.tag = Int(isRewardState.int)
        
        addMosaic()
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
