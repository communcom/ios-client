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
    // save transaction id in case of non-completed creating community process
    var savedTransactionId: [String: String]? {
        get {
            UserDefaults.standard.value(forKey: "CreateCommunityVC.savedTransactionId") as? [String: String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CreateCommunityVC.savedTransactionId")
        }
    }
    
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
    var createdCommunities: [ResponseAPIContentGetCommunity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieving undone community
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
        RestAPIManager.instance.getCreatedCommunities()
            .subscribe(onSuccess: { (result) in
                self.hideHud()
                self.createdCommunities = result.communities
                if let community = result.communities?.last(where: {$0.isDone == false || $0.currentStep != "done"}),
                    let transactionId = self.savedTransactionId?[community.communityId]
                {
                    self.showAlert(title: "continue".localized().uppercaseFirst + "?", message: "you haven't finished creating community" + " \"" + community.name + "\".\n" + "would you like to continue creating it?".localized().uppercaseFirst, buttonTitles: ["OK", "create a new one".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
                        if index == 0 {
                            self.communityNameTextField.text = community.name
                            self.avatarImageView.setAvatar(urlString: community.avatarUrl)
                            self.showIndetermineHudWithMessage("creating community".localized().uppercaseFirst)
                            self.startCommunityCreation(communityId: community.communityId, trxId: transactionId)
                                .subscribe(onSuccess: { (communityId) in
                                    self.handleCommunityCreated(communityId: communityId)
                                }) { (error) in
                                    self.handleCommunityCreationError(error: error)
                                }
                                .disposed(by: self.disposeBag)
                        }
                    }
                }
            }, onError: {_ in
                self.hideHud()
            })
            .disposed(by: disposeBag)
    }
    
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
        let description = self.descriptionTextView.text ?? ""
        
        showIndetermineHudWithMessage("creating community".localized().uppercaseFirst)
        
        let single: Single<String>
        if let uncompletedCreatingCommunity = createdCommunities?.first(where: {$0.name == name}),
            uncompletedCreatingCommunity.currentStep != "done"
        {
            single = startCommunityCreation(communityId: uncompletedCreatingCommunity.communityId)
        } else {
            single = RestAPIManager.instance.createNewCommunity(name: name)
                .flatMap { result -> Single<(ResponseAPICommunityCreateNewCommunity, String)> in
                    if !self.didSetAvatar || self.avatarImageView.image == nil { return .just((result, "")) }
                    return RestAPIManager.instance.uploadImage(self.avatarImageView.image!)
                        .map {(result, $0)}
                }
                .flatMap { (result, imageUrl) in
                    return RestAPIManager.instance.commmunitySetSettings(name: name, description: description, language: language, communityId: result.community.communityId, avatarUrl: imageUrl)
                        .map {_ in result.community.communityId}
                }
                .flatMap {communityId in
                    BlockchainManager.instance.transferPoints(to: "communcreate", number: 10000, currency: "CMN", memo: "for community: \(communityId)")
                        .do(onSuccess: {
                            if self.savedTransactionId == nil {self.savedTransactionId = [String: String]()}
                            self.savedTransactionId?[communityId] = $0
                        })
                        .flatMap {RestAPIManager.instance.waitForTransactionWith(id: $0).andThen(Single<(String, String)>.just((communityId, $0)))}
                }
                .flatMap { (communityId, trxId) in
                    self.startCommunityCreation(communityId: communityId, trxId: trxId)
                }
        }
            
        single
            .subscribe(onSuccess: { communityId in
                self.handleCommunityCreated(communityId: communityId)
            }) { (error) in
                self.handleCommunityCreationError(error: error)
            }
            .disposed(by: disposeBag)
    }
    
    func startCommunityCreation(communityId: String, trxId: String? = nil) -> Single<String> {
        let trxId = trxId ?? savedTransactionId?[communityId]
        return RestAPIManager.instance.startCommunityCreation(communityId: communityId, transferTrxId: trxId)
            .do(onSuccess: {_ in self.savedTransactionId?[communityId] = nil})
            .map {_ in communityId}
            .flatMap {communityId in
                BlockchainManager.instance.regLeader(communityId: communityId)
                    .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                    .andThen(Single<String>.just(communityId))
            }
            .flatMap {communityId in
                BlockchainManager.instance.voteLeader(communityId: communityId, leader: Config.currentUser?.id ?? "")
                    .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                    .andThen(Single<String>.just(communityId))
            }
    }
    
    func handleCommunityCreated(communityId: String) {
        self.hideHud()
        self.dismiss(animated: true) {
            let vc = CreateCommunityCompletedVC()
            vc.communityId = communityId
            UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let disposeBag = appDelegate.disposeBag
            BlockchainManager.instance.followCommunity(communityId).subscribe().disposed(by: disposeBag)
        }
    }
    
    func handleCommunityCreationError(error: Error) {
        self.hideHud()
        self.showError(error)
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
