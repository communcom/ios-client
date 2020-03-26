//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditVC: BaseViewController {
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical, contentInset: UIEdgeInsets(inset: 16))
    lazy var avatarImageView: MyAvatarImageView = {
        let imageView = MyAvatarImageView(size: 120)
        imageView.borderWidth = 5
        imageView.borderColor = .white
        imageView.setToCurrentUserAvatar()
        return imageView
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: 150, cornerRadius: 7, contentMode: .scaleAspectFit)
        imageView.borderWidth = 7
        imageView.borderColor = .white
        imageView.setCover(urlString: UserDefaults.standard.string(forKey: Config.currentUserCoverUrlKey))
        return imageView
    }()
    
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        return tf
    }()
    
    lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        return tf
    }()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        return tv
    }()
    
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        scrollView.contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 20)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(coverImageView)
        coverImageView.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 25)
        coverImageView.autoPinEdge(toSuperviewEdge: .leading)
        coverImageView.autoPinEdge(toSuperviewEdge: .trailing)
        
        let nameContainerView: UIView = {
            let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
            containerView.borderWidth = 1
            containerView.borderColor = .e2e6e8
            let label = UILabel.with(text: "name".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
            containerView.addSubview(label)
            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
            
            containerView.addSubview(nameTextField)
            nameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
            nameTextField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
            return containerView
        }()
        
        scrollView.contentView.addSubview(nameContainerView)
        nameContainerView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: 20)
        nameContainerView.autoPinEdge(toSuperviewEdge: .leading)
        nameContainerView.autoPinEdge(toSuperviewEdge: .trailing)
    
        let usernameContainerView: UIView = {
            let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
            containerView.borderWidth = 1
            containerView.borderColor = .e2e6e8
            let label = UILabel.with(text: "username".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
            containerView.addSubview(label)
            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
            
            containerView.addSubview(usernameTextField)
            usernameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
            usernameTextField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
            return containerView
        }()
        
        scrollView.contentView.addSubview(usernameContainerView)
        usernameContainerView.autoPinEdge(.top, to: .bottom, of: nameContainerView, withOffset: 10)
        usernameContainerView.autoPinEdge(toSuperviewEdge: .leading)
        usernameContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        let bioContainerView: UIView = {
            let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
            containerView.borderWidth = 1
            containerView.borderColor = .e2e6e8
            let label = UILabel.with(text: "bio".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
            containerView.addSubview(label)
            label.autoPinTopAndLeadingToSuperView(inset: 11, xInset: 15)
            
            containerView.addSubview(bioTextView)
            bioTextView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 11, right: 15), excludingEdge: .top)
            bioTextView.autoPinEdge(.top, to: .bottom, of: label, withOffset: 8)
            return containerView
        }()
        
        scrollView.contentView.addSubview(bioContainerView)
        bioContainerView.autoPinEdge(.top, to: .bottom, of: usernameContainerView, withOffset: 10)
        bioContainerView.autoPinEdge(toSuperviewEdge: .leading)
        bioContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        bioContainerView.autoPinEdge(toSuperviewEdge: .bottom)
        
        view.addSubview(saveButton)
        saveButton.autoPinEdge(.top, to: .bottom, of: scrollView)
        saveButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        saveButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        saveButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
    }
}
