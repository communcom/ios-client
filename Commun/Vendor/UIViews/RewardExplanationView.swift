//
//  PostRewardExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 7/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class StateButtonRewardsVC: BaseViewController {
    let post: ResponseAPIContentGetPost
    
    lazy var swipeDownButton = UIView(width: 50, height: 5, backgroundColor: .appWhiteColor, cornerRadius: 2.5)
    lazy var showingOptionButtonLabel = UILabel.with(text: "community points".localized().uppercaseFirst, textColor: .appGrayColor)
    lazy var rewardsVC: PostRewardsVC = {
        let vc = PostRewardsVC(post: post)
        vc.modelSelected = {donation in
            self.dismiss(animated: true) {
                UIApplication.topViewController()?.showProfileWithUserId(donation.sender.userId)
            }
        }
        
        vc.donateButtonHandler = {
            vc.dismiss(animated: true) {
                var post = self.post
                post.showDonationButtons = true
                post.notifyChanged()
            }
        }
        return vc
    }()
    
    init(post: ResponseAPIContentGetPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var showingOptionButton: UIStackView = {
        let view = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        let dropdownButton = UIButton.circleGray(imageName: "drop-down")
        dropdownButton.isUserInteractionEnabled = false
        view.addArrangedSubviews([showingOptionButtonLabel, dropdownButton])
        return view
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rewardsVC.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .clear
        
        addChild(rewardsVC)
        
        let stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .center, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let showInView = UIView(height: 50, backgroundColor: .appWhiteColor, cornerRadius: 25)
        let showInLabel = UILabel.with(text: "show in".localized().uppercaseFirst)
        showInView.addSubview(showInLabel)
        showInLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), excludingEdge: .trailing)
        showInView.addSubview(showingOptionButton)
        showingOptionButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), excludingEdge: .leading)
        showInLabel.autoPinEdge(.trailing, to: .leading, of: showingOptionButton, withOffset: -10)
        
        stackView.addArrangedSubviews([swipeDownButton, showInView, rewardsVC.view])
        rewardsVC.didMove(toParent: self)
        
        showInView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        rewardsVC.view.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        swipeDownButton.isUserInteractionEnabled = true
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownButtonDidTouch(_:)))
        gesture.direction = .down
        swipeDownButton.addGestureRecognizer(gesture)
        
        showingOptionButton.isUserInteractionEnabled = true
        showingOptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInDropdownDidTouch)))
    }
    
    override func bind() {
        super.bind()
        UserDefaults.standard.rx.observe(String.self, Config.currentRewardShownSymbol)
            .subscribe(onNext: { (symbol) in
                let symbol = symbol ?? "community points"
                self.showingOptionButtonLabel.text = symbol.localized().uppercaseFirst
            })
            .disposed(by: disposeBag)
    }
    
    @objc func swipeDownButtonDidTouch(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func showInDropdownDidTouch() {
        self.dismiss(animated: true, completion: {
            UIApplication.topViewController()?.showActionSheet(title: "show rewards in".localized().uppercaseFirst, actions: [
                UIAlertAction(title: "USD", style: .default, handler: { (_) in
                    UserDefaults.standard.set("USD", forKey: Config.currentRewardShownSymbol)
                }),
                UIAlertAction(title: "CMN", style: .default, handler: { (_) in
                    UserDefaults.standard.set("CMN", forKey: Config.currentRewardShownSymbol)
                }),
                UIAlertAction(title: "community points".localized().uppercaseFirst, style: .default, handler: { (_) in
                    UserDefaults.standard.set("community points", forKey: Config.currentRewardShownSymbol)
                })
            ])
        })
    }
}
