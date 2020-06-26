//
//  UserProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class UserProfileHeaderView: ProfileHeaderView, ProfileController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    var isCommunitiesHidden: Bool = false {
        didSet {
            showCommunities()
        }
    }

    // MARK: - Subviews
    lazy var communitiesView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.layer.masksToBounds = false
        return view
    }()

    lazy var seeAllButton: UIButton = UIButton(label: String(format: "%@ %@", "see".localized(), "all".localized()), labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
    
    lazy var communitiesLabel = UILabel.with(numberOfLines: 2)
    
    lazy var communitiesCollectionView: UICollectionView = {
        let collectionView = UICollectionView.horizontalFlow(
            cellType: CommunityCollectionCell.self,
            height: 187,
            contentInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            backgroundColor: .clear
        )
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    lazy var separator1 = UIView(height: 2, backgroundColor: .appLightGrayColor)
    lazy var separator2 = UIView(height: 2, backgroundColor: .appLightGrayColor)
    
    // MARK: - Initializers
    override func commonInit() {
        super.commonInit()

        // set
        communitiesView.addSubview(communitiesLabel)
        communitiesLabel.autoPinTopAndLeadingToSuperView()
        
        communitiesView.addSubview(seeAllButton)
        seeAllButton.autoPinEdge(toSuperviewEdge: .trailing)
        seeAllButton.autoPinEdge(toSuperviewEdge: .top)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonDidTouch), for: .touchUpInside)

        communitiesView.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdge(.top, to: .bottom, of: communitiesLabel, withOffset: 16)
        communitiesCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        setUpStackView()
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "comments".localized().uppercaseFirst)
        ]
    }
    
    func setUpStackView() {
        stackView.addArrangedSubviews([
            headerStackView,
            descriptionLabel,
            statsLabel,
            separator1,
            communitiesView,
            separator2
        ])
        
        stackView.setCustomSpacing(10, after: headerStackView)
        stackView.setCustomSpacing(16, after: descriptionLabel)
        stackView.setCustomSpacing(25, after: statsLabel)
        stackView.setCustomSpacing(16, after: separator1)
        stackView.setCustomSpacing(0, after: communitiesView)
    }

    private func showCommunities() {
        communitiesView.isHidden = isCommunitiesHidden
        separator1.isHidden = isCommunitiesHidden
    }
    
    func setUp(with userProfile: ResponseAPIContentGetProfile) {
        self.profile = userProfile
        
        if self.profile?.isInBlacklist == true {
            self.profile?.isSubscribed = false
        }
        
        // avatar
        if let avatarURL = userProfile.avatarUrl {
            avatarImageView.setAvatar(urlString: avatarURL)
            avatarImageView.addTapToViewer(with: avatarURL)
        }
        
        // name
        let attributedText = NSMutableAttributedString()
            .text(userProfile.username, size: 20, weight: .bold)
            .text("\n")
            .text(Formatter.joinedText(with: userProfile.registration?.time), size: 12, weight: .semibold, color: .appGrayColor)
        headerLabel.attributedText = attributedText
        
        // bio
        descriptionLabel.text = nil
        
        if let description = userProfile.personal?.biography?.trimmed {
            if description.count <= 180 {
                descriptionLabel.text = description
            } else {
                descriptionLabel.text = String(description.prefix(177)) + "..."
            }
        }
        
        // stats
        let followingsCount: Int = Int((userProfile.subscriptions?.usersCount ?? 0))
        let followersCount: Int = Int((userProfile.subscribers?.usersCount ?? 0))
        
        let aStr = NSMutableAttributedString()
            .bold(followersCount.kmFormatted, font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("followers-count", comment: ""), followersCount), font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
            .bold(statsSeparator, font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
            .bold("\(followingsCount.kmFormatted)", font: .boldSystemFont(ofSize: 15))
            .bold(" ")
            .bold(String(format: NSLocalizedString("followings-count", comment: ""), followingsCount), font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
        
        if userProfile.isSubscription == true {
            aStr
                .bold(statsSeparator, font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
                .bold("follows you".localized().uppercaseFirst, font: .boldSystemFont(ofSize: 12), color: .appGrayColor)
        }
        
        statsLabel.attributedText = aStr

        communitiesLabel.attributedText = NSMutableAttributedString()
            .text("communities".localized().uppercaseFirst, size: 20, weight: .bold)
            .text("\n")
            .text("\(userProfile.subscriptions?.communitiesCount ?? 0) (\(userProfile.highlightCommunitiesCount ?? 0) " + "mutual".localized().uppercaseFirst + ")", size: 15, weight: .semibold, color: .appGrayColor)

        if userProfile.userId != Config.currentUser?.id {
            isCommunitiesHidden = !(userProfile.highlightCommunitiesCount ?? 0 > 0)
            followButton.setHightLight(userProfile.isSubscribed == true, highlightedLabel: "following", unHighlightedLabel: "follow")
            followButton.isEnabled = !(profile?.isBeingToggledFollow ?? false)
        }
    }
    
    override func joinButtonDidTouch() {
        toggleFollow()
    }
    
    @objc func seeAllButtonDidTouch() {
        let vc = SubscriptionsVC(title: profile?.username, userId: profile?.userId, type: .community)
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        parentViewController?.present(navigation, animated: true, completion: nil)
    }
    
    override func statsLabelDidTouchAtIndex(_ index: Int) {
        if index < (statsLabel.text?.count ?? 0) / 2 {
            followersDidTouch()
        } else {
            followingDidTouch()
        }
    }
    
    @objc func followersDidTouch() {
        let vc = SubscribersVC(title: self.profile?.username, userId: self.profile?.userId)
        vc.dismissModalWhenPushing = true
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        self.parentViewController?.present(navigation, animated: true, completion: nil)
    }
    
    @objc func followingDidTouch() {
        let vc = SubscriptionsVC(title: self.profile?.username, userId: self.profile?.userId, type: .user)
        vc.dismissModalWhenPushing = true
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        self.parentViewController?.present(navigation, animated: true, completion: nil)
    }
}
