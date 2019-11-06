//
//  UserProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class UserProfileHeaderView: ProfileHeaderView, ProfileController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    var firstSeparatorBottomConstraint: NSLayoutConstraint?

    // MARK: - Subviews
    lazy var followButton = CommunButton.default(label: "follow".localized().uppercaseFirst)

    lazy var communitiesView = UIView(forAutoLayout: ())

    lazy var separatorForCommunities: UIView = UIView(height: 2, backgroundColor: #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1))
    lazy var firstSeparator: UIView = UIView(height: 2, backgroundColor: #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1))

    lazy var followersCountLabel: UILabel = {
        let label = UILabel.with(text: Double(10000000).kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var followingsCountLabel: UILabel = {
        let label = UILabel.with(text: Double(10000000).kmFormatted, textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var seeAllButton: UIButton = UIButton(label: "see all".localized(), labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
    
    lazy var communitiesCountLabel = UILabel.with(text: "1,2 k", textSize: 15, weight: .semibold, textColor: .a5a7bd)
    
    lazy var communitiesMutualCountLabel = UILabel.with(text: "300", textSize: 15, weight: .semibold, textColor: .a5a7bd)
    
    lazy var communitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.autoSetDimension(.height, toSize: 187)
        return collectionView
    }()
    
    // MARK: - Initializers
    override func commonInit() {
        super.commonInit()
        
        addSubview(followButton)
        followButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        followButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        followButton.addTarget(self, action: #selector(followButtonDidTouch(_:)), for: .touchUpInside)
        
        addSubview(followersCountLabel)
        followersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        followersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 22)

        let followersLabel = UILabel.with(text: "followers".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(followersLabel)
        followersLabel.autoPinEdge(.leading, to: .trailing, of: followersCountLabel, withOffset: 4)
        followersLabel.autoAlignAxis(.horizontal, toSameAxisOf: followersCountLabel)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(followersLabelDidTouch))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(tap1)
        
        let dotLabel = UILabel.with(text: "•", textSize: 15, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(dotLabel)
        dotLabel.autoPinEdge(.leading, to: .trailing, of: followersLabel, withOffset: 2)
        dotLabel.autoPinEdge(.bottom, to: .bottom, of: followersLabel)
        
        addSubview(followingsCountLabel)
        followingsCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel, withOffset: 2)
        followingsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: followersCountLabel)
        
        let followingsLabel = UILabel.with(text: "followings".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        addSubview(followingsLabel)
        followingsLabel.autoPinEdge(.leading, to: .trailing, of: followingsCountLabel, withOffset: 4)
        followingsLabel.autoAlignAxis(.horizontal, toSameAxisOf: followersCountLabel)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(follwingLabelDidTouch))
        followingsLabel.isUserInteractionEnabled = true
        followingsLabel.addGestureRecognizer(tap2)
        
        firstSeparator = UIView(height: 2, backgroundColor: #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1))
        addSubview(firstSeparator)
        firstSeparator.autoPinEdge(toSuperviewEdge: .leading)
        firstSeparator.autoPinEdge(toSuperviewEdge: .trailing)
        firstSeparator.autoPinEdge(.top, to: .bottom, of: followersCountLabel, withOffset: 16)

        // communities
        addSubview(communitiesView)
        communitiesView.autoPinEdge(.top, to: .bottom, of: firstSeparator)
        communitiesView.autoPinEdge(toSuperviewEdge: .left)
        communitiesView.autoPinEdge(toSuperviewEdge: .right)

        let communitiesLabel = UILabel.with(text: "communities".localized().uppercaseFirst, textSize: 20, weight: .bold)
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
        
        let openBraceLabel = UILabel.with(text: "(", textSize: 15, weight: .semibold, textColor: .a5a7bd)
        communitiesView.addSubview(openBraceLabel)
        openBraceLabel.autoPinEdge(.leading, to: .trailing, of: communitiesCountLabel, withOffset: 2)
        openBraceLabel.autoAlignAxis(.horizontal, toSameAxisOf: communitiesCountLabel)
        
        communitiesView.addSubview(communitiesMutualCountLabel)
        communitiesMutualCountLabel.autoPinEdge(.leading, to: .trailing, of: openBraceLabel)
        communitiesMutualCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: communitiesCountLabel)

        let mutualLabel = UILabel.with(text: "mutual".localized().uppercaseFirst + ")", textSize: 15, weight: .semibold, textColor: .a5a7bd)
        communitiesView.addSubview(mutualLabel)
        mutualLabel.autoPinEdge(.leading, to: .trailing, of: communitiesMutualCountLabel, withOffset: 2)
        mutualLabel.autoAlignAxis(.horizontal, toSameAxisOf: communitiesCountLabel)
        
        communitiesCollectionView.register(SubscriptionCommunityCell.self, forCellWithReuseIdentifier: "SubscriptionCommunityCell")
        communitiesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        communitiesView.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdge(.top, to: .bottom, of: communitiesCountLabel, withOffset: 16)
        communitiesCollectionView.autoPinEdge(toSuperviewEdge: .leading)
        communitiesCollectionView.autoPinEdge(toSuperviewEdge: .trailing)

        communitiesView.addSubview(separatorForCommunities)
        separatorForCommunities.autoPinEdge(.top, to: .bottom, of: communitiesCollectionView, withOffset: 4)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .leading)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .trailing)
        separatorForCommunities.autoPinEdge(toSuperviewEdge: .bottom)

        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: communitiesView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        let separator = UIView(height: 10, backgroundColor: #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1))
        addSubview(separator)
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        segmentedControl.items = [
            CMSegmentedControl.Item(name: "posts".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "comments".localized().uppercaseFirst)
        ]
        
        observeProfileChange()
    }

    private func needShowCommunites(_ show: Bool) {
        if firstSeparatorBottomConstraint == nil {
            firstSeparatorBottomConstraint = firstSeparator.autoPinEdge(.bottom, to: .top, of: segmentedControl)
        }
        communitiesView.isHidden = !show
        firstSeparatorBottomConstraint?.isActive = !show
    }
    
    func setUp(with userProfile: ResponseAPIContentGetProfile) {
        self.profile = userProfile
        
        // avatar
        avatarImageView.setAvatar(urlString: userProfile.personal?.avatarUrl, namePlaceHolder: userProfile.username)
        
        // name
        nameLabel.text = userProfile.username
        
        // join date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date.from(string: userProfile.registration.time))
        joinedDateLabel.text = String(format: "%@ %@", "joined".localized().uppercaseFirst, dateString)
        
        // followButton
        let isFollowing = userProfile.isSubscribed ?? false
        followButton.backgroundColor = isFollowing ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        followButton.setTitleColor(isFollowing ? .appMainColor: .white , for: .normal)
        followButton.setTitle(isFollowing ? "following".localized().uppercaseFirst : "follow".localized().uppercaseFirst, for: .normal)
        
        // bio
        // description
        descriptionLabel.text = nil
        if let description = userProfile.personal?.biography {
            if description.count <= 180 {
                descriptionLabel.text = description
            }
            else {
                descriptionLabel.text = String(description.prefix(177)) + "..."
            }
        }
        
        #warning("fix these number later")
        // stats
        followersCountLabel.text = "\(userProfile.subscribers?.usersCount ?? 0)"
        followingsCountLabel.text = "\(userProfile.subscriptions?.usersCount ?? 0)"
        communitiesCountLabel.text = "\(userProfile.subscriptions?.communitiesCount ?? 0)"
        communitiesMutualCountLabel.text = "\(userProfile.commonCommunitiesCount ?? 0)"

        needShowCommunites(userProfile.commonCommunitiesCount ?? 0 > 0)
    }
    
    @objc func followButtonDidTouch(_ sender: UIButton) {
        toggleFollow()
    }
    
    @objc func seeAllButtonDidTouch() {
        let vc = SubscriptionsVC(title: profile?.username, userId: profile?.userId, type: .community)
        parentViewController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func follwingLabelDidTouch() {
        let vc = SubscriptionsVC(title: profile?.username, userId: profile?.userId, type: .user)
        parentViewController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func followersLabelDidTouch() {
        let vc = SubscribersVC(title: profile?.username, userId: profile?.userId)
        parentViewController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}
