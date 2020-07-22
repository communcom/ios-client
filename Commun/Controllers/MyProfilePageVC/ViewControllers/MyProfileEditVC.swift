//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditVC: BaseVerticalStackVC {
    // MARK: - Subviews
    lazy var generalInfoStackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
    
    var spacer: UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
//    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Sections
    lazy var generalInfoView: UIView = {
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.addSubview(generalInfoStackView)
        generalInfoStackView.autoPinEdgesToSuperviewEdges()
        return view
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
        
        reloadData()
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubview(generalInfoView)
    }
    
    // MARK: - Data handler
    func reloadData() {
        // general info
        updateGeneralInfo()
    }
    
    func updateGeneralInfo() {
        let stackView = generalInfoStackView
        stackView.removeArrangedSubviews()
        
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
            imageView.setCover(urlString: UserDefaults.standard.string(forKey: Config.currentUserCoverUrlKey))
            return imageView
        }()
        
        stackView.addArrangedSubviews([
            headerView,
            avatarImageView,
            coverImageView
        ])
        
        let spacer1 = spacer
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: Config.currentUser?.name)
        let spacer2 = spacer
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.id ?? ""))
        
        let infoFields: [UIView] = [
            spacer1,
            nameInfoField,
            spacer2,
            usernameInfoField
        ]
        stackView.addArrangedSubviews(infoFields)
        
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
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
}
