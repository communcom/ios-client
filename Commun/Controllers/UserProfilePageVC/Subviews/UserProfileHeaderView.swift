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
    var followingsCount: Int { Int((profile?.subscriptions?.usersCount ?? 0)) }
    var followersCount: Int { Int((profile?.subscribers?.usersCount ?? 0)) }

    // MARK: - Subviews
    lazy var buttonStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var contactButton: CommunButton = {
        let button = CommunButton.default(label: "message", isHuggingContent: false)
        button.addTarget(self, action: #selector(buttonContactDidTouch), for: .touchUpInside)
        return button
    }()
    
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
            CMSegmentedControl.Item(name: "comments".localized().uppercaseFirst),
            CMSegmentedControl.Item(name: "about".localized().uppercaseFirst)
        ]
    }
    
    func setUpStackView() {
        followButton.removeFromSuperview()
        buttonStackView.addArrangedSubviews([contactButton, followButton])
        
        stackView.addArrangedSubviews([
            headerStackView,
            buttonStackView,
            descriptionLabel,
            statsLabel,
            separator1,
            communitiesView,
            separator2
        ])
        
        stackView.setCustomSpacing(10, after: headerStackView)
        stackView.setCustomSpacing(20, after: buttonStackView)
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
            .text(userProfile.personal?.fullName ?? userProfile.username ?? "", size: 20, weight: .bold)
            .text("\n")
        
        let subtitle = "@\(userProfile.username ?? userProfile.userId)"

        attributedText
            .text(subtitle, size: 12, weight: .semibold, color: .appMainColor)
        
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
            .text("\(userProfile.subscriptions?.communitiesCount ?? 0) (\(userProfile.commonCommunitiesCount ?? 0) " + "mutual".localized().uppercaseFirst + ")", size: 15, weight: .semibold, color: .appGrayColor)

        if userProfile.userId != Config.currentUser?.id {
            isCommunitiesHidden = !(userProfile.highlightCommunitiesCount ?? 0 > 0)
            followButton.setHightLight(userProfile.isSubscribed == true, highlightedLabel: "following", unHighlightedLabel: "follow")
            followButton.isEnabled = !(profile?.isBeingToggledFollow ?? false)
        }
        
        // message button
        if let defaultContacts = profile?.personal?.defaultContacts,
            !defaultContacts.isEmpty
        {
            followButton.setContentHuggingPriority(.required, for: .horizontal)
            contactButton.isHidden = false
            
            let text = "message".localized().uppercaseFirst
//            if defaultContacts.count > 0 {
//                text += "..."
//            }
            contactButton.setTitle(text, for: .normal)
        } else {
            followButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
            contactButton.isHidden = true
        }
    }
    
    override func joinButtonDidTouch() {
        if !authorizationRequired {
            (parentViewController as? NonAuthVCType)?.showAuthVC()
            return
        }
        toggleFollow()
    }
    
    @objc func seeAllButtonDidTouch() {
        let vc = SubscriptionsVC(title: profile?.username, userId: profile?.userId, type: .community)
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        parentViewController?.present(navigation, animated: true, completion: nil)
    }
    
    override func statsLabelDidTouchAtIndex(_ index: Int) {
        if !authorizationRequired {
            (parentViewController as? NonAuthVCType)?.showAuthVC()
            return
        }
        guard let text = statsLabel.text,
            let dotIndex = text.index(of: statsSeparator)?.utf16Offset(in: text)
        else {return}

        if index < dotIndex {
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
    
    @objc func buttonContactDidTouch() {
        guard let profile = profile,
            let filledContacts = profile.personal?.messengers?.filledContacts,
            !filledContacts.isEmpty
        else {return}
        let actions = filledContacts.sorted(by: {$0.value.default == true || $1.value.default == false}).map {contact -> CMActionSheet.Action in
            let action = CMActionSheet.Action.customLayout(height: 63, title: contact.key.rawValue.uppercaseFirst, spacing: 16, iconName: contact.key.rawValue + "-icon", iconSize: 20, showIconFirst: true, showNextButton: true, bottomMargin: 10) {
                self.openChat(messengerType: contact.key, link: contact.value)
            }
            
            let aString = NSMutableAttributedString()
                .text(contact.key.rawValue.uppercaseFirst, size: 14, weight: .semibold, color: .appGrayColor)
            
            if contact.value.default == true {
                aString
                    .text(" (" + "preferrable".localized().uppercaseFirst + ")", size: 14, weight: .semibold, color: .appGrayColor)
            }
                
            if let value = contact.value.value {
                aString.text("\n")
                    .text(value, size: 14, weight: .semibold, color: .appMainColor)
                    .withParagraphStyle(lineSpacing: 5)
            }
            
            action.titleLabel?.numberOfLines = 0
            action.titleLabel?.attributedText = aString
            
            return action
        }
        
        parentViewController?.showCMActionSheet(actions: actions)
    }
    
    private func openChat(messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType, link: ResponseAPIContentGetProfilePersonalLink) {
        guard let link = link.value else {return}
        switch messengerType {
        case .telegram:
            let screenName =  link
            let appURL = NSURL(string: "tg://resolve?domain=\(screenName)")!
            let webURL = NSURL(string: "https://t.me/\(screenName)")!
            if UIApplication.shared.canOpenURL(appURL as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appURL as URL)
                }
            } else {
                //redirect to safari because the user doesn't have Telegram
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(webURL as URL)
                }
            }
        default:
            break
        }
    }
}
