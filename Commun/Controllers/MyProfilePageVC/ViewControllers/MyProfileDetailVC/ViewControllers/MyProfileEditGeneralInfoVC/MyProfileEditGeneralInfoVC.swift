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
        let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleToFill)
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
        super.setUp()
        title = "general info".localized().uppercaseFirst
        scrollView.keyboardDismissMode = .onDrag
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
            nameTextField.rx.text,
            usernameTextField.rx.text,
            websiteTextField.rx.text,
            bioTextView.rx.text
        )
            .map { (avatar, cover, name, username, website, bio) -> Bool in
                // define if should enable save button
                if avatar != self.originalAvatarImage {return true}
                if cover != self.originalCoverImage {return true}
                // TODO: - Compare name
                if name != self.profile?.personal?.contacts?.fullName {return true}
                if username != self.profile?.username {return true}
                if website != self.profile?.personal?.contacts?.websiteUrl?.value {return true}
                if bio != (self.profile?.personal?.biography ?? "") {return true}
                return false
            }
            .bind(to: saveButton.rx.isDisabled)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data handler
    override func reloadData() {
        super.reloadData()
        updateViews()
    }
    
    // MARK: - View builders
    private func createTextField() -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        return tf
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
        let pickerVC = SinglePhotoPickerVC()
        
        pickerVC.completion = { image in
            let coverEditVC = MyProfileEditCoverVC()
            coverEditVC.modalPresentationStyle = .fullScreen
            coverEditVC.joinedDateString = self.profile?.registration?.time
            coverEditVC.updateWithImage(image)
            coverEditVC.completion = {image in
                coverEditVC.dismiss(animated: true, completion: {
                    pickerVC.dismiss(animated: true, completion: nil)
                })
                self.coverImageView.image = image
            }
            
            let nc = SwipeNavigationController(rootViewController: coverEditVC)
            pickerVC.present(nc, animated: true, completion: nil)
        }
        
        pickerVC.modalPresentationStyle = .fullScreen
        self.present(pickerVC, animated: true, completion: nil)
    }
}
