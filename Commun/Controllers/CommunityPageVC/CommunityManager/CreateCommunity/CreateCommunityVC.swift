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

protocol CreateCommunityVCType: BaseViewController {
    var isDataValid: BehaviorRelay<Bool> {get}
}

class CreateCommunityVC: CreateCommunityFlowVC {
    // MARK: - Properties
    // save transaction id in case of non-completed creating community process
    var savedTransactionId: [String: String]? {
        get {
            UserDefaults.standard.value(forKey: "CreateCommunityVC.savedTransactionId") as? [String: String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CreateCommunityVC.savedTransactionId")
        }
    }
    var createdCommunities: [ResponseAPIContentGetCommunity]?
    var currentPageIndex = 0
    var community: ResponseAPIContentGetCommunity?
    
    // MARK: - Child VCs
    lazy var firstStepVC = CreateCommmunityFirstStepVC()
    lazy var topicsVC = CreateTopicsVC()
    lazy var rulesVC = CreateRulesVC()
    lazy var confirmVC = CreateCommunityConfirmVC()
    lazy var viewControllers: [CreateCommunityVCType] = [firstStepVC, rulesVC, confirmVC]
    
    // MARK: - Subviews
    lazy var containerView = UIView(forAutoLayout: ())
    lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    lazy var bottomStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalCentering)
    lazy var backButton = UIButton(height: 50, label: "back".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#E9EEFC")!.inDarkMode(#colorLiteral(red: 0.1725490196, green: 0.1843137255, blue: 0.2117647059, alpha: 1)), textColor: .appMainColor, cornerRadius: 25, contentInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
        .onTap(self, action: #selector(backButtonDidTouch))
    lazy var pageControl = CMPageControll(numberOfPages: viewControllers.count)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // retrieving undone community
//        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
//        RestAPIManager.instance.getCreatedCommunities()
//            .subscribe(onSuccess: { (result) in
//                self.hideHud()
//                self.createdCommunities = result.communities
//                if let community = result.communities?.last(where: {$0.isDone == false || $0.currentStep != "done"}),
//                    let transactionId = self.savedTransactionId?[community.communityId]
//                {
//                    self.showAlert(title: "continue".localized().uppercaseFirst + "?", message: "you haven't finished creating community" + " \"" + community.name + "\".\n" + "would you like to continue creating it?".localized().uppercaseFirst, buttonTitles: ["OK", "create a new one".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
//                        if index == 0 {
//                            self.firstStepVC.communityNameTextField.text = community.name
//                            self.firstStepVC.avatarImageView.setAvatar(urlString: community.avatarUrl)
//                            self.showIndetermineHudWithMessage("creating community".localized().uppercaseFirst)
//                            self.startCommunityCreation(communityId: community.communityId, trxId: transactionId)
//                                .subscribe(onSuccess: { (communityId) in
//                                    self.handleCommunityCreated(communityId: communityId)
//                                }) { (error) in
//                                    self.handleCommunityCreationError(error: error)
//                                }
//                                .disposed(by: self.disposeBag)
//                        }
//                    }
//                }
//            }, onError: {_ in
//                self.hideHud()
//            })
//            .disposed(by: disposeBag)
    }
    
    override func setUp() {
        super.setUp()
        // fix continue button
        continueButton.cornerRadius = 25
        continueButton.setTitle("next".localized().uppercaseFirst, for: .normal)
        continueButton.removeFromSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // remove scrollView and add containerView
        scrollView.removeFromSuperview()
        
        let contentStackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
        view.addSubview(contentStackView)
        contentStackView.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: headerStackViewEdgeInsets.bottom)
        contentStackView.autoPinEdge(toSuperviewEdge: .leading)
        contentStackView.autoPinEdge(toSuperviewEdge: .trailing)
        contentStackView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
        
        // bottom stackView
        let bottomView: UIView = {
            let bottomView = UIView(backgroundColor: view.backgroundColor)
            bottomView.addSubview(bottomStackView)
            bottomStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10))
            bottomStackView.addArrangedSubviews([backButton, pageControl, continueButton])
            return bottomView
        }()
        
        contentStackView.addArrangedSubviews([containerView, bottomView])
        
        // dismiss keyboard
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        // add pageVC
        addChild(pageVC)
        pageVC.view.configureForAutoLayout()
        containerView.addSubview(pageVC.view)
        pageVC.view.autoPinEdgesToSuperviewEdges()
        pageVC.didMove(toParent: self)
        
        // kick off first screen
        moveToStep(currentPageIndex)
    }
    
    override func bind() {
        super.bind()
        Observable.combineLatest(viewControllers.map {$0.isDataValid})
            .map {$0[self.currentPageIndex]}
            .asDriver(onErrorJustReturn: false)
            .drive(continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        UIResponder.keyboardHeightObservable
            .filter {_ in self.pageVC.viewControllers?.first == self.topicsVC}
            .map {$0 > 0}
            .asDriver(onErrorJustReturn: false)
            .drive(bottomStackView.superview!.rx.isHidden)
            .disposed(by: disposeBag)

        firstStepVC.languageRelay
            .map {$0?.code ?? "en"}
            .subscribe(onNext: { (code) in
                self.rulesVC.languageCode = code
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Page control
    func moveToStep(_ index: Int) {
        guard let vc = viewControllers[safe: index] else { return }
        endEditing()
        pageVC.setViewControllers([vc], direction: index > currentPageIndex ? .forward : .reverse, animated: true, completion: nil)
        pageControl.selectedIndex = index
        backButton.alpha = index > 0 ? 1 : 0
        currentPageIndex = index
        // refresh validation
        vc.isDataValid.accept(vc.isDataValid.value)
        
        // change title
        var title = "create community"
        var continueTitle = "next"
        switch vc {
        case topicsVC:
            title = "select community topics"
        case rulesVC:
            title = "add community rules"
        case confirmVC:
            title = "important information"
            continueTitle = "create"
        default:
            break
        }
        titleLabel.text = title.localized().uppercaseFirst
        continueButton.setTitle(continueTitle.localized().uppercaseFirst, for: .normal)
    }
    
    // MARK: - Actions
    @objc func backButtonDidTouch() {
        moveToStep(currentPageIndex - 1)
    }
    
    override func continueButtonDidTouch() {
        // next button
        guard currentPageIndex == viewControllers.count - 1 else {
            // move to next step
            if let vc = viewControllers[safe: currentPageIndex] {
                switch vc {
                case firstStepVC:
                    showIndetermineHudWithMessage("verifying...".localized().uppercaseFirst)
                    firstStepVC.createCommunity()
                        .subscribe(onSuccess: { (community) in
                            self.hideHud()
                            self.community = community
                            if community.currentStep == "openGalleryBalance" {
                                // Community creation has already started, cannot change settings
                                self.showAlert(title: "continue".localized().uppercaseFirst, message: "Community creation has already started, cannot change settings".localized().uppercaseFirst + ".", buttonTitles: ["OK"], highlightedButtonIndex: 0) { (_) in
                                    self.openBalanceAndStartCreation(communityId: community.communityId)
                                        .subscribe(onSuccess: { communityId in
                                            self.handleCommunityCreated(communityId: communityId)
                                        }) { (error) in
                                            self.handleCommunityCreationError(error: error)
                                        }
                                        .disposed(by: self.disposeBag)
                                }
                                return
                            } else {
                                self.moveToStep(self.currentPageIndex + 1)
                            }
                        }) { (error) in
                            self.hideHud()
                            self.showError(error)
                        }
                        .disposed(by: disposeBag)
                    return
                case topicsVC:
                    community?.subject = topicsVC.itemsRelay.value.convertToJSON()
                case rulesVC:
                    community?.rules = rulesVC.itemsRelay.value
                default:
                    break
                }

                self.moveToStep(self.currentPageIndex + 1)
            }
            
            return
        }
        
        view.endEditing(true)
        
        guard var community = community else {return}
        
        showIndetermineHudWithMessage("creating community".localized().uppercaseFirst)
        
        let single: Single<String>
        if let uncompletedCreatingCommunity = createdCommunities?.first(where: {$0.name == community.name}),
            uncompletedCreatingCommunity.currentStep != "done"
        {
            single = startCommunityCreation(communityId: uncompletedCreatingCommunity.communityId)
        } else {
            single = firstStepVC.uploadImages()
                .observeOn(MainScheduler.instance)
                .flatMap { urls in
                    community.avatarUrl = urls.avatar
                    community.coverUrl = urls.cover
                    community.description = self.firstStepVC.descriptionTextView.text ?? ""
                    community.language = self.firstStepVC.languageRelay.value?.code
                    return RestAPIManager.instance.commmunitySetSettings(
                        name: community.name,
                        description: community.description ?? "",
                        language: community.language ?? "en",
                        communityId: community.communityId,
                        avatarUrl: community.avatarUrl ?? "",
                        coverUrl: community.coverUrl ?? "",
                        subject: community.subject ?? "",
                        rules: community.rules.convertToJSON()
                    )
                        .map {_ in community.communityId}
                }
                .flatMap { self.openBalanceAndStartCreation(communityId: $0) }
        }
            
        single
            .subscribe(onSuccess: { communityId in
                self.handleCommunityCreated(communityId: communityId)
            }) { (error) in
                self.handleCommunityCreationError(error: error)
            }
            .disposed(by: disposeBag)
    }
    
    func openBalanceAndStartCreation(communityId: String) -> Single<String> {
        BlockchainManager.instance.transferPoints(to: "communcreate", number: 10000, currency: "CMN", memo: "for community: \(communityId)")
            .do(onSuccess: {
                if self.savedTransactionId == nil {self.savedTransactionId = [String: String]()}
                self.savedTransactionId?[communityId] = $0
            })
            .flatMap {RestAPIManager.instance.waitForTransactionWith(id: $0).andThen(Single<String>.just($0))}
            .flatMap {self.startCommunityCreation(communityId: communityId, trxId: $0)}
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
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    override func fittingHeightInContainer(safeAreaFrame: CGRect) -> CGFloat {
        safeAreaFrame.height
    }
}
