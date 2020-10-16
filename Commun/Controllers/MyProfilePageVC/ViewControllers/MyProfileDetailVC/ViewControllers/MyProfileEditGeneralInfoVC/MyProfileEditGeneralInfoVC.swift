//
//  MyProfileEditGeneralInfoVC.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileEditGeneralInfoVC: MyProfileDetailFlowVC {
    // MARK: - Properties
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
    lazy var changeAvatarButton: UIButton = {
        let button = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
        button.addTarget(self, action: #selector(chooseAvatarButtonDidTouch), for: .touchUpInside)
        return button
    }()
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleAspectFill)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 335 / 150).isActive = true
        imageView.setCover(urlString: profile?.coverUrl, namePlaceHolder: "cover-placeholder")
        originalCoverImage = imageView.image
        return imageView
    }()
    lazy var changeCoverButton: UIButton = {
        let button = UIButton.circle(size: 44, backgroundColor: .clear, imageName: "profile-edit-change-image")
        button.addTarget(self, action: #selector(chooseCoverButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    lazy var firstNameTextField = createTextField(allowWhiteSpaces: true)
    lazy var lastNameTextField = createTextField()
//    lazy var usernameTextField = createTextField()
    lazy var websiteTextField = createTextField()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    lazy var saveButton: CommunButton = {
        let button = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false)
        button.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "general info".localized().uppercaseFirst
        scrollView.keyboardDismissMode = .onDrag
        
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
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
    
    override func bind() {
        super.bind()
        
        Observable.combineLatest(
            avatarImageView.imageView.rx.observe(Optional<UIImage>.self, "image"),
            coverImageView.rx.observe(Optional<UIImage>.self, "image"),
            firstNameTextField.rx.text.orEmpty,
            lastNameTextField.rx.text.orEmpty,
//            usernameTextField.rx.text.orEmpty,
            websiteTextField.rx.text.orEmpty,
            bioTextView.rx.text.orEmpty
        )
            .map { _ in self.dataHasChanged()}
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data handler
    func dataHasChanged() -> Bool {
        if avatarImageView.image != self.originalAvatarImage {return true}
        if coverImageView.image != self.originalCoverImage {return true}
        if (firstNameTextField.text ?? "").trimmed != (self.profile?.personal?.firstName ?? "").trimmed {return true}
        if (lastNameTextField.text ?? "").trimmed != (self.profile?.personal?.lastName ?? "").trimmed {return true}
//                if username.trimmed != self.profile?.username {return true}
        if (websiteTextField.text ?? "").trimmed != (self.profile?.personal?.websiteUrl ?? "").trimmed {return true}
        
        if (bioTextView.text ?? "").trimmed != (self.profile?.personal?.biography ?? "").trimmed {return true}
        return false
    }
    
    override func reloadData() {
        super.reloadData()
        updateViews()
    }
    
    // MARK: - Actions
    @objc private func chooseAvatarButtonDidTouch() {
        // On updating
        let chooseAvatarVC = ProfileChooseAvatarVC.fromStoryboard("ProfileChooseAvatarVC", withIdentifier: "ProfileChooseAvatarVC")
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (image) in
                self.avatarImageView.image = image
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func chooseCoverButtonDidTouch() {
        showCoverImagePicker(joinedDateString: self.profile?.registration?.time) { (image) in
            self.coverImageView.image = image
        }
    }
    
    @objc private func saveButtonDidTouch() {
        view.endEditing(true)
        
        var singles = [Single<String>]()
        
        var avatarHasChanged = false
        var coverHasChanged = false
        if let image = avatarImageView.image,
            image != self.originalAvatarImage
        {
            avatarHasChanged = true
            singles.append(RestAPIManager.instance.uploadImage(image))
        }
        if let image = coverImageView.image,
            image != self.originalCoverImage
        {
            coverHasChanged = true
            singles.append(RestAPIManager.instance.uploadImage(image))
        }
        
        var params = [String: String]()
        var profile = self.profile
        if let firstName = firstNameTextField.text,
            firstName.trimmed != self.profile?.personal?.firstName
        {
            params["first_name"] = firstName
            profile?.personal?.firstName = firstName
        }
        
        if let lastName = lastNameTextField.text,
            lastName.trimmed != self.profile?.personal?.lastName
        {
            params["last_name"] = lastName
            profile?.personal?.lastName = lastName
        }
        
//        if let username = usernameTextField.text,
//            username.trimmed != self.profile?.username
//        {
//            params["username"]
//        }
        
        if let website = websiteTextField.text,
            website.trimmed != (self.profile?.personal?.websiteUrl ?? "")
        {
            params["website_url"] = website
            profile?.personal?.websiteUrl = website
        }
        
        if let bio = bioTextView.text,
            bio.trimmed != (self.profile?.personal?.biography ?? "")
        {
            params["biography"] = bio
            profile?.personal?.biography = bio
        }
        
        showIndetermineHudWithMessage("saving".localized().uppercaseFirst + "...")
        Single<String>.zip(singles)
            .map { strings -> [String: String] in
                if avatarHasChanged {
                    profile?.avatarUrl = strings.first
                    params["avatar_url"] = strings.first
                }
                if coverHasChanged {
                    profile?.coverUrl = strings.last
                    params["cover_url"] = strings.last
                }
                return params
            }
            .flatMapCompletable {BlockchainManager.instance.updateProfile(params: $0, waitForTransaction: false)}
            .subscribe(onCompleted: {
                ResponseAPIContentGetProfile.current = profile
                self.hideHud()
                self.showDone("saved".localized().uppercaseFirst)
                self.saveButton.isEnabled = false
                self.back()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func askForSavingAndGoBack() {
        if dataHasChanged() {
            showAlert(title: "save".localized().uppercaseFirst, message: "do you want to save the changes you've made?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.saveButtonDidTouch()
                    return
                }
                self.back()
            }
        } else {
            back()
        }
    }
}
