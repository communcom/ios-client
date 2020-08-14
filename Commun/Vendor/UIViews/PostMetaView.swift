//
//  PostTitleView.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class PostMetaView: MyView {
    // MARK: - Enums
    class TapGesture: UITapGestureRecognizer {
        var community: ResponseAPIContentGetCommunity?
        var author: ResponseAPIContentGetProfile?
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var stackViewTrailingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    private var mosaic: ResponseAPIRewardsGetStateBulkMosaic?

    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 40)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 3, alignment: .leading)
    lazy var comunityNameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var subtitleLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .appGrayColor)
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
        
        // currency changed
        UserDefaults.standard.rx.observe(String.self, Config.currentRewardShownSymbol)
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { _ in
                self.setMosaic()
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        setUp(with: post.community, author: post.author, creationTime: post.meta.creationTime)
        self.mosaic = post.mosaic
        setMosaic()
    }
    
    func setUp(comment: ResponseAPIContentGetComment) {
        setUp(with: comment.community, author: comment.author, creationTime: comment.meta.creationTime)
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity?, author: ResponseAPIContentGetProfile?, creationTime: String) {
        let isMyFeed = community?.communityId == "FEED"
        avatarImageView.setAvatar(urlString: isMyFeed ? author?.avatarUrl : community?.avatarUrl)
        comunityNameLabel.text = isMyFeed ? author?.username : community?.name
        
        subtitleLabel.attributedText = NSMutableAttributedString()
            .text(Date.timeAgo(string: creationTime) + " • ", size: 12, weight: .semibold, color: .appGrayColor)
            .text(isMyFeed ? (community?.name ?? community?.communityId ?? "") : (author?.username ?? author?.userId ?? ""), size: 12, weight: .semibold, color: .appMainColor)
        
        // add gesture
        if isUserNameTappable {
            let tap = TapGesture(target: self, action: isMyFeed ? #selector(communityNameTapped(_:)) : #selector(userNameTapped(_:)))
            tap.community = community
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.addGestureRecognizer(tap)
        }
        
        if isCommunityNameTappable {
            let tapLabel = TapGesture(target: self, action: isMyFeed ? #selector(userNameTapped(_:)) : #selector(communityNameTapped(_:)))
            let tapAvatar = TapGesture(target: self, action: isMyFeed ? #selector(userNameTapped(_:)) : #selector(communityNameTapped(_:)))
            tapLabel.author = author
            tapLabel.community = community
            tapAvatar.author = author
            tapAvatar.community = community

            avatarImageView.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(tapAvatar)
            comunityNameLabel.isUserInteractionEnabled = true
            comunityNameLabel.addGestureRecognizer(tapLabel)
        }
    }
    
    private func setMosaic() {
        // clean
        stateButton.removeFromSuperview()
        stackViewTrailingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        trailingConstraint = nil
        
        guard let mosaicItem = mosaic, mosaicItem.isRewarded else {
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
        
        var value = ""
        
        let symbol = UserDefaults.standard.string(forKey: Config.currentRewardShownSymbol)
        
        if !isRewardState {
            value = "in top".localized().uppercaseFirst + ": "
        }
        
        if symbol == "USD" {
            value += ((mosaicItem.convertedReward?.usd ?? "") + " $")
        } else if symbol == "CMN" {
            value += ((mosaicItem.convertedReward?.cmn ?? "") + " CMN")
        } else {
            value += mosaicItem.rewardDouble.currencyValueFormatted
        }
        
        stateButtonLabel.text = value
        stateButton.tag = Int(isRewardState.int)
    }
    
    // MARK: - Actions
    @objc func userNameTapped(_ sender: TapGesture) {
        guard let userId = sender.author?.userId else {return}
        if parentViewController?.isModal == true,
            let parentVC = parentViewController?.presentingViewController
        {
            var vcToShow = parentVC
            if let tabBar = parentVC as? TabBarVC {
                vcToShow = tabBar.selectedViewController!
            }
            parentViewController?.dismiss(animated: true, completion: {
                vcToShow.showProfileWithUserId(userId)
            })
            return
        }
        parentViewController?.showProfileWithUserId(userId)
    }
    
    @objc func communityNameTapped(_ sender: TapGesture) {
        guard let communityId = sender.community?.communityId else {return}
        if parentViewController?.isModal == true,
            let parentVC = parentViewController?.presentingViewController
        {
            var vcToShow = parentVC
            if let tabBar = parentVC as? TabBarVC {
                vcToShow = tabBar.selectedViewController!
            }
            parentViewController?.dismiss(animated: true, completion: {
                vcToShow.showCommunityWithCommunityId(communityId)
            })
            return
        }
        parentViewController?.showCommunityWithCommunityId(communityId)
    }
    
    @objc func stateButtonTapped(_ gesture: UITapGestureRecognizer) {
        let rewardExplanationView = RewardExplanationView(params: gesture.view?.tag == 0 ? .topState : .rewardState)
        rewardExplanationView.delegate = self
        let postLink = "https://commun.com/faq?#What%20else%20can%20you%20do%20with%20the%20points?"
        rewardExplanationView.explanationView.completionDismissWithAction = { value in
            self.parentViewController?.dismiss(animated: true, completion: {
                if value, let baseVC = self.parentViewController as? BaseViewController {
                    baseVC.load(url: postLink)
                }
            })
        }
        parentViewController?.showCardWithView(rewardExplanationView, backgroundColor: .clear)
    }
}

extension PostMetaView: RewardExplanationViewDelegate {
    func rewardExplanationViewDidTapOnShowInDropdown(_ rewardExplanationView: RewardExplanationView) {
        self.parentViewController?.dismiss(animated: true, completion: {
            UIApplication.topViewController()?.showActionSheet(title: "show rewards in".localized().uppercaseFirst, actions: [
                UIAlertAction(title: "USD", style: .default, handler: { (_) in
                    UserDefaults.standard.set("USD", forKey: Config.currentRewardShownSymbol)
                }),
                UIAlertAction(title: "CMN", style: .default, handler: { (_) in
                    UserDefaults.standard.set("CMN", forKey: Config.currentRewardShownSymbol)
                }),
                UIAlertAction(title: "community points".localized().uppercaseFirst, style: .default, handler: { (_) in
                    UserDefaults.standard.set("community points", forKey: Config.currentRewardShownSymbol)
                })
            ])
        })
    }
}
