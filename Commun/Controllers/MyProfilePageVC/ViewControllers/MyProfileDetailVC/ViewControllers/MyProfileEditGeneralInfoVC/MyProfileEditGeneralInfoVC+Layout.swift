//
//  MyProfileEditGeneralInfoVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfileEditGeneralInfoVC {
    func updateViews() {
        // add views
        contentView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        // image wrappers
        let avatarWrapper = UIView(forAutoLayout: ())
        avatarWrapper.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges()
        avatarWrapper.addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        
        let coverWrapper = UIView(forAutoLayout: ())
        coverWrapper.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges()
        coverWrapper.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -16)
        
        stackView.addArrangedSubviews([
            avatarWrapper,
            coverWrapper
        ])
        
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // name
        nameTextField.text = profile?.personal?.contacts?.fullName
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, editor: nameTextField)
        stackView.addArrangedSubview(nameInfoField)
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // username
        usernameTextField.text = profile?.username
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, editor: usernameTextField)
        stackView.addArrangedSubview(usernameInfoField)
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // website
        websiteTextField.text = profile?.personal?.contacts?.websiteUrl?.value
        let websiteInfoField = infoField(title: "website".localized().uppercaseFirst, editor: websiteTextField)
        stackView.addArrangedSubview(websiteInfoField)
        websiteInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // bio
        bioTextView.text = profile?.personal?.biography
        let bioField = infoField(title: "bio".localized().uppercaseFirst, editor: bioTextView)
        stackView.addArrangedSubview(bioField)
        bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0)
        
        stackView.setCustomSpacing(29, after: avatarWrapper)
        stackView.setCustomSpacing(30, after: coverWrapper)
        stackView.setCustomSpacing(10, after: nameInfoField)
        stackView.setCustomSpacing(10, after: usernameInfoField)
        stackView.setCustomSpacing(10, after: websiteInfoField)
        stackView.setCustomSpacing(10, after: bioField)
    }
    
    private func infoField(title: String, editor: UITextEditor) -> UIView {
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        
        stackView.addArrangedSubviews([titleLabel, editor])
        editor.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32)
            .isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        
        let field = UIView(cornerRadius: 10)
        field.borderColor = .appLightGrayColor
        field.borderWidth = 1
        field.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        return field
    }
}
