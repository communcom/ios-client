//
//  UserProfileInfoView.swift
//  Commun
//
//  Created by Chung Tran on 9/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
protocol UserProfileInfoViewDelegate: class {
    func userProfileInfoViewGeneralInfoTitleDidTouch(_ userProfileInfoView: UserProfileInfoView)
    func userProfileInfoViewLinksTitleDidTouch(_ userProfileInfoView: UserProfileInfoView)
    func userProfileInfoViewContactsTitleDidTouch(_ userProfileInfoView: UserProfileInfoView)
}

extension UserProfileInfoViewDelegate where Self: MyProfileDetailVC {
    func userProfileInfoViewGeneralInfoTitleDidTouch(_ userProfileInfoView: UserProfileInfoView) {
        editGeneralInfo()
    }
    func userProfileInfoViewLinksTitleDidTouch(_ userProfileInfoView: UserProfileInfoView) {
        editLinks()
    }
    func userProfileInfoViewContactsTitleDidTouch(_ userProfileInfoView: UserProfileInfoView) {
        editContacts()
    }
}

class UserProfileInfoView: MyView {
    lazy var stackView = UIStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
    lazy var generalInfoView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var contactsView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var linksView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var joinedDateView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    weak var delegate: UserProfileInfoViewDelegate?
    
    var shouldAddArrowToHeader: Bool {false}
    
    var isInfoEmpty = true
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.addArrangedSubviews([
            generalInfoView,
            contactsView,
            linksView,
            joinedDateView
        ])
    }
    
    func setUp(with profile: ResponseAPIContentGetProfile) {
        isInfoEmpty = true
        updateGeneralInfo(profile: profile)
        updateLinks(profile: profile)
        updateContacts(profile: profile)
        updateJoinedDate(profile: profile)
    }
    
    func updateGeneralInfo(profile: ResponseAPIContentGetProfile) {
        var isGeneralInfoEmpty = true
        generalInfoView.isHidden = false
        
        generalInfoView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        generalInfoView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "about".localized().uppercaseFirst, action: #selector(generalInfoTitleDidTouch))
        
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        if let biography = profile.personal?.biography, !biography.trimmed.isEmpty {
            isGeneralInfoEmpty = false
            let spacer1 = separator()
            let bioField = infoField(title: "bio".localized().uppercaseFirst, content: profile.personal?.biography)
            stackView.addArrangedSubviews([spacer1, bioField])
            spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            stackView.setCustomSpacing(0, after: spacer1)
        }
        
        // website
        if let website = profile.personal?.websiteUrl, !website.trimmed.isEmpty {
            isGeneralInfoEmpty = false
            let spacer2 = separator()
            let websiteField = infoField(title: "website".localized().uppercaseFirst, content: profile.personal?.websiteUrl)
            stackView.addArrangedSubviews([spacer2, websiteField])
            spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            websiteField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        isInfoEmpty = isInfoEmpty && isGeneralInfoEmpty
        
        if isGeneralInfoEmpty {
            handleGeneralInfoEmpty()
        }
    }
    
    func handleGeneralInfoEmpty() {
        generalInfoView.isHidden = true
    }
    
    func updateContacts(profile: ResponseAPIContentGetProfile) {
        var isContactsEmpty = true
        contactsView.isHidden = false
        contactsView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        contactsView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "contacts".localized().uppercaseFirst, action: #selector(contactsInfoTitleDidTouch))
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // whatsapp
        if let username = profile.personal?.messengers?.whatsApp?.value {
            isContactsEmpty = false
            addContactField(icon: "whatsapp-icon", serviceName: "Whatsapp", username: username, to: stackView)
        }
        
        // telegram
        if let username = profile.personal?.messengers?.telegram?.value {
            isContactsEmpty = false
            addContactField(icon: "telegram-icon", serviceName: "Telegram", username: username, to: stackView)
        }
        
        // wechat
        if let username = profile.personal?.messengers?.weChat?.value {
            isContactsEmpty = false
            addContactField(icon: "wechat-icon", serviceName: "WeChat", username: username, to: stackView)
        }
        
        isInfoEmpty = isInfoEmpty && isContactsEmpty
        
        if isContactsEmpty {
            handleContactEmpty()
        }
    }
    
    func handleContactEmpty() {
        contactsView.isHidden = true
    }
    
    func updateLinks(profile: ResponseAPIContentGetProfile) {
        var isLinkEmpty = true
        linksView.isHidden = false
        linksView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        linksView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "links".localized().uppercaseFirst, action: #selector(linkInfoTitleDidTouch))
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // twitter
        if let username = profile.personal?.links?.twitter?.value {
            isLinkEmpty = false
            addContactField(icon: "twitter-icon", serviceName: "Twitter", username: username, to: stackView)
        }
        
        // facebook
        if let username = profile.personal?.links?.facebook?.value {
            isLinkEmpty = false
            addContactField(icon: "facebook-icon", serviceName: "Facebook", username: username, to: stackView)
        }
        
        // instagram
        if let username = profile.personal?.links?.instagram?.value {
            isLinkEmpty = false
            addContactField(icon: "instagram-icon", serviceName: "Instagram", username: username, to: stackView)
        }
        
        // github
        if let username = profile.personal?.links?.gitHub?.value {
            isLinkEmpty = false
            addContactField(icon: "github-icon", iconTintColor: .appBlackColor, serviceName: "Github", username: username, to: stackView)
        }
        
        // linkedin
        if let username = profile.personal?.links?.linkedin?.value {
            isLinkEmpty = false
            addContactField(icon: "linkedin-icon", serviceName: "Linkedin", username: username, to: stackView)
        }
        
        isInfoEmpty = isInfoEmpty && isLinkEmpty
        
        if isLinkEmpty {
            handleLinksEmpty()
        }
    }
    
    func handleLinksEmpty() {
        linksView.isHidden = true
    }
    
    fileprivate func updateJoinedDate(profile: ResponseAPIContentGetProfile) {
        var joinedDateLabel: UILabel
        if let label = joinedDateView.viewWithTag(1) as? UILabel {
            joinedDateLabel = label
        } else {
            joinedDateLabel = UILabel.with(textSize: 15, weight: .medium, textColor: .appGrayColor)
            joinedDateLabel.tag = 1
            joinedDateView.addSubview(joinedDateLabel)
            joinedDateLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16))
        }
        joinedDateLabel.text = Formatter.joinedText(with: profile.registration?.time)
    }
    
    // MARK: - View builders
    fileprivate func sectionHeaderView(title: String, action: Selector) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.autoSetDimension(.height, toSize: 55)
        let label = UILabel.with(text: title, textSize: 17, weight: .semibold)
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubviews([label, arrow])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        arrow.addTarget(self, action: action, for: .touchUpInside)
        arrow.isHidden = !shouldAddArrowToHeader
        return stackView
    }
    
    fileprivate func infoField(title: String, content: String?, showArrow: Bool = false) -> UIStackView {
        let hStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        let contentLabel = UILabel.with(text: content ?? " ", textSize: 17, weight: .semibold, textColor: .appBlackColor, numberOfLines: 0)
        stackView.addArrangedSubviews([titleLabel, contentLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        let arrow = UIButton.nextArrow()
        hStackView.addArrangedSubviews([stackView, arrow])
        arrow.isHidden = !showArrow
        return hStackView
    }
    
    @discardableResult
    fileprivate func addContactField(icon: String?, iconTintColor: UIColor? = nil, serviceName: String, username: String?, to parentStackView: UIStackView) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let icon = UIImageView(width: 20, height: 20, imageNamed: icon)
        if let tintColor = iconTintColor {
            icon.tintColor = tintColor
        }
        let label = UILabel.with(textSize: 14, numberOfLines: 2)
        label.attributedText = NSMutableAttributedString()
            .text(serviceName, size: 14, weight: .semibold, color: .appGrayColor)
            .text("\n")
            .text("@" + (username ?? ""), size: 14, weight: .semibold, color: .appMainColor)
            .withParagraphStyle(lineSpacing: 5)
        stackView.addArrangedSubviews([icon, label])
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubview(arrow)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let spacer1 = separator()
        parentStackView.addArrangedSubviews([spacer1, stackView])
        spacer1.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
        
        return stackView
    }
    
    func separator() -> UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
    // MARK: - Actions
    @objc func generalInfoTitleDidTouch() {
        delegate?.userProfileInfoViewGeneralInfoTitleDidTouch(self)
    }
    
    @objc func linkInfoTitleDidTouch() {
        delegate?.userProfileInfoViewLinksTitleDidTouch(self)
    }
    
    @objc func contactsInfoTitleDidTouch() {
        delegate?.userProfileInfoViewContactsTitleDidTouch(self)
    }
}

class MyProfileInfoView: UserProfileInfoView {
    override var shouldAddArrowToHeader: Bool {true}
    
    override func commonInit() {
        super.commonInit()
        joinedDateView.isHidden = true
    }
    
    override func updateGeneralInfo(profile: ResponseAPIContentGetProfile) {
        generalInfoView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        generalInfoView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "general info".localized().uppercaseFirst, action: #selector(generalInfoTitleDidTouch))
        
        let avatarImageView: MyAvatarImageView = {
            let imageView = MyAvatarImageView(size: 120)
            imageView.setToCurrentUserAvatar()
            return imageView
        }()
        
        let coverImageView: UIImageView = {
            let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleAspectFill)
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 335 / 150).isActive = true
            imageView.setCover(urlString: profile.coverUrl, namePlaceHolder: "cover-placeholder")
            return imageView
        }()
        
        stackView.addArrangedSubviews([
            headerView,
            avatarImageView,
            coverImageView
        ])
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // name
        let spacer1 = separator()
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: profile.personal?.fullName)
        
        stackView.addArrangedSubviews([spacer1, nameInfoField])
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // username
        let spacer2 = separator()
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.name ?? ""))
        stackView.addArrangedSubviews([spacer2, usernameInfoField])
        spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer3 = separator()
        let websiteField = infoField(title: "website".localized().uppercaseFirst, content: profile.personal?.websiteUrl)
        stackView.addArrangedSubviews([spacer3, websiteField])
        spacer3.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        websiteField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer4 = separator()
        let bioField = infoField(title: "bio".localized().uppercaseFirst, content: profile.personal?.biography)
        stackView.addArrangedSubviews([spacer4, bioField])
        spacer4.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        stackView.setCustomSpacing(29, after: avatarImageView)
        stackView.setCustomSpacing(12, after: coverImageView)
        stackView.setCustomSpacing(0, after: spacer1)
    }
    
    override func addContactField(icon: String?, iconTintColor: UIColor? = nil, serviceName: String, username: String?, to parentStackView: UIStackView) -> UIStackView {
        let contactField = super.addContactField(icon: icon, iconTintColor: iconTintColor, serviceName: serviceName, username: username, to: parentStackView)
        // hide arrow
        contactField.arrangedSubviews.last?.isHidden = true
        return contactField
    }
    
    override func handleGeneralInfoEmpty() {
        // do nothing
    }
    
    override func handleContactEmpty() {
        // do nothing
    }
    
    override func handleLinksEmpty() {
        // do nothing
    }
}
