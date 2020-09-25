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
    lazy var firstStepVC = CreateCommmunityFirstStepVC()
    lazy var viewControllers = [firstStepVC]
    
    lazy var containerView = UIView(forAutoLayout: ())
    lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    lazy var bottomStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .equalCentering)
    lazy var backButton = UIButton(width: 100, height: 50, label: "back".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1), textColor: .appMainColor, cornerRadius: 25)
    lazy var pageControl = CMPageControll(numberOfPages: viewControllers.count)
    
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
                            self.firstStepVC.communityNameTextField.text = community.name
                            self.firstStepVC.avatarImageView.setAvatar(urlString: community.avatarUrl)
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
        
        // fix continue button
        continueButton.autoSetDimensions(to: CGSize(width: 100, height: 50))
        continueButton.cornerRadius = 25
        continueButton.setTitle("next".localized().uppercaseFirst, for: .normal)
        continueButton.removeFromSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // remove scrollView and add containerView
        scrollView.removeFromSuperview()
        
        view.addSubview(containerView)
        containerView.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: headerStackViewEdgeInsets.bottom)
        containerView.autoPinEdge(toSuperviewEdge: .leading)
        containerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        // bottom stackView
        let bottomView: UIView = {
            let bottomView = UIView(backgroundColor: view.backgroundColor)
            bottomView.addSubview(bottomStackView)
            bottomStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10))
            bottomStackView.addArrangedSubviews([backButton, pageControl, continueButton])
            return bottomView
        }()
        view.addSubview(bottomView)
        bottomView.autoPinEdge(.top, to: .bottom, of: containerView)
        bottomView.autoPinEdge(toSuperviewSafeArea: .leading)
        bottomView.autoPinEdge(toSuperviewSafeArea: .trailing)
        bottomView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
        
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
        pageVC.setViewControllers([firstStepVC], direction: .forward, animated: true, completion: nil)
    }
    
    override func continueButtonDidTouch() {
//        view.endEditing(true)
//        
//        guard let name = firstStepVC.communityNameTextField.text,
//            let language = languageRelay.value?.code
//        else {return}
//        let description = self.descriptionTextView.text ?? ""
//        
//        showIndetermineHudWithMessage("creating community".localized().uppercaseFirst)
//        
//        let single: Single<String>
//        if let uncompletedCreatingCommunity = createdCommunities?.first(where: {$0.name == name}),
//            uncompletedCreatingCommunity.currentStep != "done"
//        {
//            single = startCommunityCreation(communityId: uncompletedCreatingCommunity.communityId)
//        } else {
//            single = RestAPIManager.instance.createNewCommunity(name: name)
//                .flatMap { result -> Single<(ResponseAPICommunityCreateNewCommunity, String, String)> in
//                    var singles = [Single<String>]()
//                    
//                    if !self.didSetAvatar || self.avatarImageView.image == nil {
//                        singles.append(.just(""))
//                    } else {
//                        singles.append(RestAPIManager.instance.uploadImage(self.avatarImageView.image!))
//                    }
//                    
//                    if !self.didSetCover || self.coverImageView.image == nil {
//                        singles.append(.just(""))
//                    } else {
//                        singles.append(RestAPIManager.instance.uploadImage(self.coverImageView.image!))
//                    }
//                    
//                    return Single.zip(singles)
//                        .map {(result, $0[0], $0[1])}
//                }
//                .flatMap { (result, avatarUrl, coverUrl) in
//                    return RestAPIManager.instance.commmunitySetSettings(name: name, description: description, language: language, communityId: result.community.communityId, avatarUrl: avatarUrl, coverUrl: coverUrl)
//                        .map {_ in result.community.communityId}
//                }
//                .flatMap {communityId in
//                    BlockchainManager.instance.transferPoints(to: "communcreate", number: 10000, currency: "CMN", memo: "for community: \(communityId)")
//                        .do(onSuccess: {
//                            if self.savedTransactionId == nil {self.savedTransactionId = [String: String]()}
//                            self.savedTransactionId?[communityId] = $0
//                        })
//                        .flatMap {RestAPIManager.instance.waitForTransactionWith(id: $0).andThen(Single<(String, String)>.just((communityId, $0)))}
//                }
//                .flatMap { (communityId, trxId) in
//                    self.startCommunityCreation(communityId: communityId, trxId: trxId)
//                }
//        }
//            
//        single
//            .subscribe(onSuccess: { communityId in
//                self.handleCommunityCreated(communityId: communityId)
//            }) { (error) in
//                self.handleCommunityCreationError(error: error)
//            }
//            .disposed(by: disposeBag)
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
    
    override func fittingSizeInContainer(safeAreaFrame: CGRect) -> CGFloat {
        safeAreaFrame.height
    }
}
