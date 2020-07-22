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
    lazy var avatarImageView: MyAvatarImageView = {
        let imageView = MyAvatarImageView(size: 120)
        imageView.borderWidth = 5
        imageView.borderColor = .appWhiteColor
        imageView.setToCurrentUserAvatar()
        return imageView
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleAspectFit)
        imageView.borderWidth = 7
        imageView.borderColor = .appWhiteColor
        imageView.setCover(urlString: UserDefaults.standard.string(forKey: Config.currentUserCoverUrlKey))
        return imageView
    }()
    
//    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Sections
    lazy var generalInfoView: UIView = {
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        let headerView = sectionHeaderView(title: "general info".localized().uppercaseFirst)
        
        var spacer: UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
        let spacer1 = spacer
        let spacer2 = spacer
        
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: Config.currentUser?.name)
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.id ?? ""))
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(coverImageView)
        stackView.addArrangedSubview(spacer1)
        stackView.addArrangedSubview(nameInfoField)
        stackView.addArrangedSubview(spacer2)
        stackView.addArrangedSubview(usernameInfoField)
        
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        return view
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubview(generalInfoView)
    }
    
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
        return stackView
    }
    
//    override func setUp() {
//        super.setUp()
//        view.backgroundColor = .appLightGrayColor
//
//        view.addSubview(scrollView)
//        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
//
//        scrollView.contentView.addSubview(avatarImageView)
//        avatarImageView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 20)
//        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
//
//        scrollView.contentView.addSubview(coverImageView)
//        coverImageView.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 25)
//        coverImageView.autoPinEdge(toSuperviewEdge: .leading)
//        coverImageView.autoPinEdge(toSuperviewEdge: .trailing)
//
//        let nameContainerView: UIView = {
//            let containerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
//            containerView.borderWidth = 1
//            containerView.borderColor = .appLightGrayColor
//            let label = UILabel.with(text: "name".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
//            containerView.addSubview(label)
//            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
//
//            containerView.addSubview(nameTextField)
//            nameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
//            nameTextField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
//            return containerView
//        }()
//
//        scrollView.contentView.addSubview(nameContainerView)
//        nameContainerView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: 20)
//        nameContainerView.autoPinEdge(toSuperviewEdge: .leading)
//        nameContainerView.autoPinEdge(toSuperviewEdge: .trailing)
//
//        let usernameContainerView: UIView = {
//            let containerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
//            containerView.borderWidth = 1
//            containerView.borderColor = .appLightGrayColor
//            let label = UILabel.with(text: "username".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
//            containerView.addSubview(label)
//            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
//
//            containerView.addSubview(usernameTextField)
//            usernameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
//            usernameTextField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
//            return containerView
//        }()
//
//        scrollView.contentView.addSubview(usernameContainerView)
//        usernameContainerView.autoPinEdge(.top, to: .bottom, of: nameContainerView, withOffset: 10)
//        usernameContainerView.autoPinEdge(toSuperviewEdge: .leading)
//        usernameContainerView.autoPinEdge(toSuperviewEdge: .trailing)
//
//        let bioContainerView: UIView = {
//            let containerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
//            containerView.borderWidth = 1
//            containerView.borderColor = .appLightGrayColor
//            let label = UILabel.with(text: "bio".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
//            containerView.addSubview(label)
//            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
//
//            containerView.addSubview(bioTextView)
//            bioTextView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
//            bioTextView.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
//            return containerView
//        }()
//
//        scrollView.contentView.addSubview(bioContainerView)
//        bioContainerView.autoPinEdge(.top, to: .bottom, of: usernameContainerView, withOffset: 10)
//        bioContainerView.autoPinEdge(toSuperviewEdge: .leading)
//        bioContainerView.autoPinEdge(toSuperviewEdge: .trailing)
//
//        bioContainerView.autoPinEdge(toSuperviewEdge: .bottom)
//
//        view.addSubview(saveButton)
//        saveButton.autoPinEdge(.top, to: .bottom, of: scrollView)
//        saveButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
//        saveButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
//        saveButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
//    }
}
