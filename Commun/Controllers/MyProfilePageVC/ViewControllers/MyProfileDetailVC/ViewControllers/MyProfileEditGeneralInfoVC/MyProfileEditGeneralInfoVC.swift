//
//  MyProfileEditGeneralInfoVC.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditGeneralInfoVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    lazy var contentView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var avatarImageView: MyAvatarImageView = {
        let imageView = MyAvatarImageView(size: 120)
        imageView.setToCurrentUserAvatar()
        return imageView
    }()
    lazy var changeAvatarButton = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleToFill)
//        imageView.setCover(urlString: profile?.coverUrl, namePlaceHolder: "cover-placeholder")
        return imageView
    }()
    lazy var changeCoverButton = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
    
    lazy var nameTextField = createTextField()
    lazy var usernameTextField = createTextField()
    lazy var websiteTextView = createTextField()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "general info".localized().uppercaseFirst
        
        // parse current data
        if let data = UserDefaults.standard.data(forKey: Config.currentUserGetProfileKey),
            let profile = try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: data)
        {
            self.profile = profile
        }
        
        reloadData()
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubviews([
            contentView,
            saveButton
        ])
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    // MARK: - View builders
    private func createTextField() -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        return tf
    }
}
