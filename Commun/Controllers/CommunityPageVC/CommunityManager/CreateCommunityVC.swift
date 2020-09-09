//
//  CreateCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 9/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

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
    
    let countryRelay = BehaviorRelay<Country?>(value: nil)
    var didSetAvatar = false
    
    override func setUp() {
        super.setUp()
        continueButton.setTitle("create community".localized().uppercaseFirst, for: .normal)
        stackView.alignment = .center
        
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
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    override func bind() {
        super.bind()
        Observable.combineLatest(
            communityNameTextField.rx.text.orEmpty,
            countryRelay
        )
            .map({ (name, country) -> Bool in
                !name.isEmpty && (country?.language?.code != nil)
            })
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        countryRelay
            .subscribe(onNext: { (country) in
                guard let country = country else {
                    self.languageFlagImageView.isHidden = true
                    self.languageDetailLabel.text = "language".localized().uppercaseFirst
                    self.languageDetailLabel.textColor = .appGrayColor
                    return
                }
                self.languageFlagImageView.isHidden = false
                var flagImageNamed = ""
                switch country.language?.code {
                case "en":
                    flagImageNamed = "american-flag"
                case "ru":
                    flagImageNamed = "russian-flag"
                default:
                    return
                }
                self.languageFlagImageView.image = UIImage(named: flagImageNamed)
                self.languageDetailLabel.attributedText = NSMutableAttributedString()
                    .text(country.name, size: 15, weight: .medium)
                    .text("\n")
                    .text(country.language?.name ?? country.language?.code ?? "", size: 12, weight: .medium, color: .appGrayColor)
                    
            })
            .disposed(by: disposeBag)
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
        view.endEditing(true)
        
        guard let name = communityNameTextField.text,
            let language = countryRelay.value?.language?.code
        else {return}
            
        RestAPIManager.instance.createNewCommunity(name: name)
            .flatMap { result in
                let description = self.descriptionTextView.text ?? ""
                let single: Single<String>
                if !self.didSetAvatar || self.avatarImageView.image == nil {single = .just("")}
                else { single = RestAPIManager.instance.uploadImage(self.avatarImageView.image!) }
                return single
                    .flatMap {RestAPIManager.instance.commmunitySetSettings(name: name, description: description, language: language, communityId: result.community.communityId, avatarUrl: $0)}
                    .map {_ in result.community.communityId}
            }
            .flatMap {communityId in
                BlockchainManager.instance.transferPoints(to: "communcreate", number: 10000, currency: "CMN", memo: "for community: \(communityId)")
                    .flatMap {RestAPIManager.instance.waitForTransactionWith(id: $0).andThen(Single<(String, String)>.just((communityId, $0)))}
            }
            .flatMap { (communityId, trxId) in
                RestAPIManager.instance.startCommunityCreation(communityId: communityId, transferTrxId: trxId)
                    .map {_ in communityId}
            }
            .subscribe(onSuccess: { communityId in
                self.dismiss(animated: true) {
                    UIApplication.topViewController()?.present(CreateCommunityCompletedVC(), animated: true, completion: nil)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let disposeBag = appDelegate.disposeBag
                    BlockchainManager.instance.followCommunity(communityId).subscribe().disposed(by: disposeBag)
                    BlockchainManager.instance.regLeader(communityId: communityId)
                        .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                        .andThen(
                            BlockchainManager.instance.voteLeader(communityId: communityId, leader: Config.currentUser?.id ?? "")
                                .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                        ).subscribe().disposed(by: disposeBag)
                }
            }) { (error) in
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func chooseAvatarButtonDidTouch() {
        // On updating
        let chooseAvatarVC = ProfileChooseAvatarVC.fromStoryboard("ProfileChooseAvatarVC", withIdentifier: "ProfileChooseAvatarVC")
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (image) in
                self.avatarImageView.image = image
                self.didSetAvatar = true
            })
            .disposed(by: disposeBag)
    }
    
    @objc func languageFieldDidTouch() {
        UIView.performWithoutAnimation {
            self.view.endEditing(true)
        }
        
        let vc = LanguagesVC()
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectionHandler = {country in
            if country.available {
                nav.dismiss(animated: true, completion: nil)
                self.countryRelay.accept(country)
            } else {
                self.showAlert(title: "sorry".uppercaseFirst.localized(), message: "but we don’t support your region yet".uppercaseFirst.localized())
            }
        }
        
        present(nav, animated: true, completion: nil)
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
}
