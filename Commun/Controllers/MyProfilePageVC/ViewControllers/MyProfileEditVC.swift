//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    var spacer: UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
    // MARK: - Sections
    lazy var generalInfoView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var contactsView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var linksView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
        
        reloadData()
    }
    
    override func bind() {
        super.bind()
        UserDefaults.standard.rx.observe(Data.self, Config.currentUserGetProfileKey)
            .filter {$0 != nil}
            .map {$0!}
            .map {try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: $0)}
            .subscribe(onNext: { profile in
                self.profile = profile
                self.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubviews([
            generalInfoView,
            contactsView,
            linksView
        ])
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    // MARK: - Data handler
    func reloadData() {
        updateGeneralInfo()
        updateContacts()
        updateLinks()
    }
    
    func updateGeneralInfo() {
        generalInfoView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        generalInfoView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "general info".localized().uppercaseFirst)
        
        let avatarImageView: MyAvatarImageView = {
            let imageView = MyAvatarImageView(size: 120)
            imageView.borderWidth = 5
            imageView.borderColor = .appWhiteColor
            imageView.setToCurrentUserAvatar()
            return imageView
        }()
        
        let coverImageView: UIImageView = {
            let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleAspectFit)
            imageView.borderWidth = 7
            imageView.borderColor = .appWhiteColor
            imageView.setCover(urlString: profile?.coverUrl)
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
        let spacer1 = spacer
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: Config.currentUser?.name)
        
        stackView.addArrangedSubviews([spacer1, nameInfoField])
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // username
        let spacer2 = spacer
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.id ?? ""))
        stackView.addArrangedSubviews([spacer2, usernameInfoField])
        spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer3 = spacer
        let websiteField = infoField(title: "website".localized().uppercaseFirst, content: "")
        stackView.addArrangedSubviews([spacer3, websiteField])
        spacer3.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        websiteField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer4 = spacer
        let bioField = infoField(title: "bio".localized().uppercaseFirst, content: profile?.personal?.biography)
        stackView.addArrangedSubviews([spacer4, bioField])
        spacer4.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    }
    
    func updateContacts() {
        contactsView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        contactsView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "contacts".localized().uppercaseFirst)
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // whatsapp
        addContactField(icon: "whatsapp-icon", serviceName: "Whatsapp", username: profile?.personal?.contacts?.whatsApp, to: stackView)
        
        // telegram
        addContactField(icon: "telegram-icon", serviceName: "Telegram", username: profile?.personal?.contacts?.telegram, to: stackView)
        
        // wechat
        addContactField(icon: "wechat-icon", serviceName: "WeChat", username: profile?.personal?.contacts?.weChat, to: stackView)
    }
    
    func updateLinks() {
        linksView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        linksView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "links".localized().uppercaseFirst)
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // twitter
        addContactField(icon: "twitter-icon", serviceName: "Twitter", username: "", to: stackView)
        
        // facebook
        addContactField(icon: "facebook-icon", serviceName: "Facebook", username: "", to: stackView)
        
        // youtube
        addContactField(icon: "youtube-icon", serviceName: "Youtube", username: "", to: stackView)
        
        // instagram
        addContactField(icon: "instagram-icon", serviceName: "Instagram", username: "", to: stackView)
        
        // github
        addContactField(icon: "github-icon", serviceName: "Github", username: "", to: stackView)
    }
    
    // MARK: - View builders
    private func sectionHeaderView(title: String) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.autoSetDimension(.height, toSize: 55)
        let label = UILabel.with(text: title, textSize: 17, weight: .semibold)
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubviews([label, arrow])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return stackView
    }
    
    private func infoField(title: String, content: String?) -> UIStackView {
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        let contentLabel = UILabel.with(text: content, textSize: 17, weight: .semibold, textColor: .appBlackColor, numberOfLines: 0)
        stackView.addArrangedSubviews([titleLabel, contentLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        return stackView
    }
    
    private func addContactField(icon: String?, serviceName: String, username: String?, to parentStackView: UIStackView) {
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let icon = UIImageView(width: 20, height: 20, imageNamed: icon)
        let label = UILabel.with(textSize: 14, numberOfLines: 2)
        label.attributedText = NSMutableAttributedString()
            .text(serviceName, size: 14, weight: .semibold, color: .appGrayColor)
            .text("\n")
            .text("@" + (username ?? ""), size: 14, weight: .semibold, color: .appMainColor)
            .withParagraphStyle(lineSpacing: 5)
        stackView.addArrangedSubviews([icon, label])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let spacer1 = spacer
        parentStackView.addArrangedSubviews([spacer1, stackView])
        spacer1.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
    }
}
