//
//  MyProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

final class MyProfileHeaderView: UserProfileHeaderView {
    lazy var changeAvatarButton: UIButton = .changeAvatarButton

    lazy var addBioButton = UIButton(height: 35,
                                     label: String(format: "%@ %@", "add".localized().uppercaseFirst, "bio".localized()),
                                     labelFont: .boldSystemFont(ofSize: 15),
                                     backgroundColor: .appLightGrayColor,
                                     textColor: .appMainColor,
                                     cornerRadius: 35/2)
    
    lazy var walletView = CMWalletView(forAutoLayout: ())
    
    override func commonInit() {
        super.commonInit()
        
        // button
        addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        
        // bind
        bind()
    }
    
    func bind() {
        descriptionLabel.rx.observe(String.self, "text")
            .map {$0 == nil || $0?.isEmpty == true}
            .subscribe(onNext: { (shouldHideDescription) in
                self.descriptionLabel.isHidden = shouldHideDescription
                self.addBioButton.isHidden = !shouldHideDescription
            })
            .disposed(by: disposeBag)
    }
    
    override func setUpStackView() {
        super.setUpStackView()
        buttonStackView.isHidden = true
        
        setUpWalletView()
        
        stackView.insertArrangedSubview(addBioButton, at: 1)
        stackView.insertArrangedSubview(walletView, at: 3)
        
        stackView.setCustomSpacing(16, after: addBioButton)
        stackView.setCustomSpacing(28, after: walletView)
    }
    
    override func setUp(with profile: ResponseAPIContentGetProfile) {
        super.setUp(with: profile)
        communitiesLabel.attributedText = NSMutableAttributedString()
            .text("communities".localized().uppercaseFirst  + " " + "(\(profile.subscriptions?.communitiesCount ?? 0))", size: 20, weight: .bold)
        
        statsLabel.isHidden = followersCount == 0 && followingsCount == 0
    }
    
    func setUpWalletView(withError: Bool = false) {
        walletView.setUp(withError: withError)
    }
}
