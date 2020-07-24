//
//  MyProfileEditGeneralInfoVC.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileEditGeneralInfoVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    var originalAvatarImage: UIImage?
    var originalCoverImage: UIImage?
    
    // MARK: - Subviews
    lazy var contentView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var avatarImageView: MyAvatarImageView = {
        let imageView = MyAvatarImageView(size: 120)
        imageView.setToCurrentUserAvatar()
        originalAvatarImage = imageView.image
        return imageView
    }()
    lazy var changeAvatarButton = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleToFill)
        imageView.setCover(urlString: profile?.coverUrl, namePlaceHolder: "cover-placeholder")
        originalCoverImage = imageView.image
        return imageView
    }()
    lazy var changeCoverButton = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
    
    lazy var nameTextField = createTextField()
    lazy var usernameTextField = createTextField()
    lazy var websiteTextField = createTextField()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    override func setUp() {
        // parse current data
        if let data = UserDefaults.standard.data(forKey: Config.currentUserGetProfileKey),
            let profile = try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: data)
        {
            self.profile = profile
        }
        
        super.setUp()
        title = "general info".localized().uppercaseFirst
        
        scrollView.keyboardDismissMode = .onDrag
        
        reloadData()
    }
    
    override func bind() {
        super.bind()
        
        Observable.combineLatest(
            avatarImageView.imageView.rx.observe(Optional<UIImage>.self, "image"),
            coverImageView.rx.observe(Optional<UIImage>.self, "image"),
            nameTextField.rx.text,
            usernameTextField.rx.text,
            websiteTextField.rx.text,
            bioTextView.rx.text
        )
            .map { (avatar, cover, name, username, website, bio) -> Bool in
                // define if should enable save button
                if avatar != self.originalAvatarImage {return true}
                if cover != self.originalCoverImage {return true}
                if name != self.profile?.username {return true}
                if username != self.profile?.username {return true}
                // TODO: - Website
                if bio != (self.profile?.personal?.biography ?? "") {return true}
                return false
            }
            .bind(to: saveButton.rx.isDisabled)
            .disposed(by: disposeBag)
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
