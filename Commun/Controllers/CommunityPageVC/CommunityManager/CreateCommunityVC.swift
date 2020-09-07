//
//  CreateCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 9/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreateCommunityVC: CreateCommunityFlowVC {
    lazy var avatarImageView: MyAvatarImageView = {
        let imageView = MyAvatarImageView(size: 120)
        return imageView
    }()
    lazy var changeAvatarButton: UIButton = {
        let button = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
        button.addTarget(self, action: #selector(chooseAvatarButtonDidTouch), for: .touchUpInside)
        return button
    }()
    lazy var communityNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        return tf
    }()
    lazy var descriptionTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    lazy var languageFlagImageView = UIImageView.circle(size: 32)
    lazy var languageDetailLabel = UILabel.with(textSize: 15, numberOfLines: 2)
    
    override func setUp() {
        super.setUp()
        continueButton.setTitle("create community".localized().uppercaseFirst, for: .normal)
        stackView.alignment = .center
        stackView.distribution = .fill
        
        // image wrappers
        let avatarWrapper = UIView(forAutoLayout: ())
        avatarWrapper.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges()
        avatarWrapper.addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        
        // name
        let communityNameField = infoField(title: "community name".localized().uppercaseFirst, editor: communityNameTextField)
        
        // bio
        let descriptionField = infoField(title: "description".localized().uppercaseFirst + " (" + "optional".localized().uppercaseFirst + ")", editor: descriptionTextView)
        
        let languageField: UIView = {
            let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
            nextButton.isUserInteractionEnabled = false
            
            stackView.addArrangedSubview(languageFlagImageView)
            stackView.addArrangedSubview(languageDetailLabel)
            stackView.addArrangedSubview(nextButton)
            
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(languageFieldDidTouch)))
            
            return view
        }()
        
        stackView.addArrangedSubview(avatarWrapper)
        stackView.addArrangedSubview(communityNameField)
        stackView.addArrangedSubview(descriptionField)
        stackView.addArrangedSubview(languageField)
        
        communityNameField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        descriptionField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        languageField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        stackView.setCustomSpacing(56, after: avatarWrapper)
        stackView.setCustomSpacing(16, after: communityNameField)
        stackView.setCustomSpacing(16, after: descriptionField)
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
        field.backgroundColor = .appWhiteColor
        field.borderColor = .appLightGrayColor
        field.borderWidth = 1
        field.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        return field
    }
    
    override func continueButtonDidTouch() {
        // TODO: - Create community
    }
    
    @objc func chooseAvatarButtonDidTouch() {
        
    }
    
    @objc func languageFieldDidTouch() {
        let vc = CountriesVC()
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectionHandler = {country in
            AnalyticsManger.shared.countrySelected(phoneCode: country.code, available: country.available)
            if country.available {
                nav.dismiss(animated: true, completion: nil)
                
            } else {
                self.showAlert(title: "sorry".uppercaseFirst.localized(), message: "but we don’t support your region yet".uppercaseFirst.localized())
            }
        }
        
        present(nav, animated: true, completion: nil)
    }
}
