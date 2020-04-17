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
    var firstSeparatorBottomConstraint: NSLayoutConstraint?
    var isCommunitiesHidden: Bool = false {
        didSet {
            showCommunities()
        }
    }

    // MARK: - Subviews
    lazy var followButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    lazy var followingsLabel = UILabel.with(text: "followings".localized().uppercaseFirst, textSize: .adaptive(width: 12.0), weight: .bold, textColor: .appGrayColor)
    lazy var followersLabel = UILabel.with(text: "followers".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .appGrayColor)

    lazy var communitiesView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.layer.masksToBounds = false
        return view
    }()

    lazy var separatorForCommunities: UIView = UIView(height: 2, backgroundColor: .appLightGrayColor)
    lazy var firstSeparator: UIView = UIView(height: 2, backgroundColor: .appLightGrayColor)

    lazy var followersCountLabel: UILabel = {
        let label = UILabel.with(text: 10000000.kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var followingsCountLabel: UILabel = {
        let label = UILabel.with(text: 10000000.kmFormatted, textSize: 15, weight: .bold)
        return label
    }()

    lazy var followsYouLabel: UILabel = {
        let label = UILabel.with(text: "follows you".localized().uppercaseFirst, textSize: .adaptive(width: 12.0), weight: .bold, textColor: .appGrayColor)
        label.isHidden = true
        
        return label
    }()

    lazy var dotLabel2: UILabel = {
        let label = UILabel.with(text: "•", textSize: .adaptive(width: 15.0), weight: .regular, textColor: .appGrayColor)
        label.isHidden = true
        
        return label
    }()

    lazy var seeAllButton: UIButton = UIButton(label: String(format: "%@ %@", "see".localized(), "all".localized()), labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
    
    lazy var communitiesLabel = UILabel.with(text: "communities".localized().uppercaseFirst, textSize: 20, weight: .bold)
    
    lazy var communitiesCountLabel = UILabel.with(text: "1,2 k", textSize: 15, weight: .semibold, textColor: .appGrayColor)
    
    lazy var communitiesCollectionView: UICollectionView = {
        let collectionView = UICollectionView.horizontalFlow(
            cellType: CommunityCollectionCell.self,
            height: 187,
            contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
            backgroundColor: .clear
        )
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    // MARK: - Initializers
    override func commonInit() {
        super.commonInit()
        
        layoutFollowButton()
        
        addSubview(followersCountLabel)
        followersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        layoutTopOfFollowerCountLabel()

        addSubview(followersLabel)
        followersLabel.autoPinEdge(.leading, to: .trailing, of: followersCountLabel, withOffset: 4)
        followersLabel.autoPinEdge(.bottom, to: .bottom, of: followersCountLabel)

        let followersButton = UIButton(height: 44, backgroundColor: .clear)
        addSubview(followersButton)
        followersButton.autoAlignAxis(.horizontal, toSameAxisOf: followersLabel)
        followersButton.autoPinEdge(.left, to: .left, of: followersCountLabel)
        followersButton.autoPinEdge(.right, to: .right, of: followersLabel)
        followersButton.rx.tap.subscribe { _ in
            let vc = SubscribersVC(title: self.profile?.username, userId: self.profile?.userId)
            vc.dismissModalWhenPushing = true
            let navigation = BaseNavigationController(rootViewController: vc)
            navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
            self.parentViewController?.present(navigation, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        let dotLabel1 = UILabel.with(text: "•", textSize: 15, weight: .regular, textColor: .appGrayColor)
        addSubview(dotLabel1)
        dotLabel1.autoPinEdge(.leading, to: .trailing, of: followersLabel, withOffset: 2)
        dotLabel1.autoPinEdge(.bottom, to: .bottom, of: followersLabel)
        
        addSubview(followingsCountLabel)
        followingsCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel1, withOffset: 2)
        followingsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: followersCountLabel)

        addSubview(followingsLabel)
        followingsLabel.autoPinEdge(.leading, to: .trailing, of: followingsCountLabel, withOffset: .adaptive(width: 4.0))
        followingsLabel.autoPinEdge(.bottom, to: .bottom, of: followingsCountLabel)

        let followingsButton = UIButton(height: .adaptive(height: 44.0), backgroundColor: .clear)
        addSubview(followingsButton)
        followingsButton.autoAlignAxis(.horizontal, toSameAxisOf: followingsLabel)
        followingsButton.autoPinEdge(.left, to: .left, of: followingsCountLabel)
        followingsButton.autoPinEdge(.right, to: .right, of: followingsLabel)
        
        followingsButton.rx.tap
            .subscribe { _ in
                let vc = SubscriptionsVC(title: self.profile?.username, userId: self.profile?.userId, type: .user)
                vc.dismissModalWhenPushing = true
                let navigation = BaseNavigationController(rootViewController: vc)
                navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
                self.parentViewController?.present(navigation, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        addSubview(dotLabel2)
        dotLabel2.autoPinEdge(.leading, to: .trailing, of: followingsButton, withOffset: .adaptive(width: 2.0))
        dotLabel2.autoPinEdge(.bottom, to: .bottom, of: followingsLabel)
        
        addSubview(followsYouLabel)
        followsYouLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel2, withOffset: .adaptive(width: 2.0))
        followsYouLabel.autoPinEdge(.bottom, to: .bottom, of: followingsLabel)

        firstSeparator = UIView(height: 2, backgroundColor: .appLightGrayColor)
        addSubview(firstSeparator)
        firstSeparator.autoPinEdge(toSuperviewEdge: .leading)
        firstSeparator.autoPinEdge(toSuperviewEdge: .trailing)
        firstSeparator.autoPinEdge(.top, to: .bottom, of: followersCountLabel, withOffset: 28)

        // communities
        addSubview(communitiesView)
        communitiesView.autoPinEdge(.top, to: .bottom, of: firstSeparator)
        communitiesView.autoPinEdge(toSuperviewEdge: .left)
        communitiesView.autoPinEdge(toSuperviewEdge: .right)

        communitiesView.addSubview(communitiesLabel)
        communitiesLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        communitiesLabel.autoPinEdge(.top, to: .top, of: communitiesView, withOffset: 16)
        
        communitiesView.addSubview(seeAllButton)
        seeAllButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        seeAllButton.autoAlignAxis(.horizontal, toSameAxisOf: communitiesLabel)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonDidTouch), for: .touchUpInside)
        
        communitiesView.addSubview(communitiesCountLabel)
        communitiesCountLabel.autoPinEdge(.top, to: .bottom, of: communitiesLabel, withOffset: 5)
        communitiesCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)

        communitiesView.addSubview(separatorForCommunities)

        communitiesView.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdge(.top, to: .bottom, of: communitiesCountLabel, withOffset: 16)
        communitiesCollectionView.autoPinEdge(toSuperviewEdge: .leading)
        communitiesCollectionView.autoPinEdge(toSuperviewEdge: .trailing)

        separatorForCommunities.autoPinEdge(.top, to: .bottom, of: communitiesCollectionView, withOffset: 4)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .leading)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .trailing)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .bottom)

        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: communitiesView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        let separator = UIView(height: 10, backgroundColor: .appLightGrayColor)
        addSubview(separator)
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "comments".localized().uppercaseFirst)
        ]
        
    }

    private func showCommunities() {
        if firstSeparatorBottomConstraint == nil {
            firstSeparatorBottomConstraint = firstSeparator.autoPinEdge(.bottom, to: .top, of: segmentedControl)
        }
        communitiesView.isHidden = isCommunitiesHidden
        firstSeparatorBottomConstraint?.isActive = isCommunitiesHidden
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
        nameLabel.text = userProfile.username
        
        // join date
        joinedDateLabel.text = Formatter.joinedText(with: userProfile.registration?.time)
        
        // followButton
        let isFollowing = userProfile.isSubscribed ?? false
        setUpFollowButton(isFollowing: isFollowing)
        
        // bio
        descriptionLabel.text = nil
        
        if let description = userProfile.personal?.biography?.trimmed {
            if description.count <= 180 {
                descriptionLabel.text = description
            } else {
                descriptionLabel.text = String(description.prefix(177)) + "..."
            }
        }
        
        // TODO: - Fix these number later
        // stats
        let followingsCount: Int = Int((userProfile.subscriptions?.usersCount ?? 0))
        let followersCount: Int = Int((userProfile.subscribers?.usersCount ?? 0))

        followersCountLabel.text = "\(followersCount)"
        followingsCountLabel.text = "\(followingsCount)"
        followingsLabel.text = String(format: NSLocalizedString("followings-count", comment: ""), followingsCount)
        followersLabel.text = String(format: NSLocalizedString("followers-count", comment: ""), followersCount)

        communitiesCountLabel.text = "\(userProfile.subscriptions?.communitiesCount ?? 0) (\(userProfile.highlightCommunitiesCount ?? 0) " + "mutual".localized().uppercaseFirst + ")"

        if userProfile.userId != Config.currentUser?.id {
            isCommunitiesHidden = !(userProfile.highlightCommunitiesCount ?? 0 > 0)
        }
        
        if let boolValue = userProfile.isSubscribed {
            dotLabel2.isHidden = !boolValue
            followsYouLabel.isHidden = !boolValue
        }
    }
    
    func layoutFollowButton() {
        addSubview(followButton)
        followButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        followButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        followButton.addTarget(self, action: #selector(followButtonDidTouch(_:)), for: .touchUpInside)
        followButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
            .isActive = true
    }
    
    func layoutTopOfFollowerCountLabel() {
        followersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 18)
    }
    
    func setUpFollowButton(isFollowing: Bool) {
        followButton.setHightLight(isFollowing, highlightedLabel: "following", unHighlightedLabel: "follow")
        followButton.isEnabled = !(profile?.isBeingToggledFollow ?? false)
    }
    
    @objc func followButtonDidTouch(_ sender: UIButton) {
        toggleFollow()
    }
    
    @objc func seeAllButtonDidTouch() {
        let vc = SubscriptionsVC(title: profile?.username, userId: profile?.userId, type: .community)
        let navigation = BaseNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        parentViewController?.present(navigation, animated: true, completion: nil)
    }
}
