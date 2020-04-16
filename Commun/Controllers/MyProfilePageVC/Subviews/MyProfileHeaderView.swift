//
//  MyProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

final class MyProfileHeaderView: UserProfileHeaderView {
    lazy var changeAvatarButton: UIButton = {
        let button = UIButton(width: 20, height: 20, backgroundColor: .f3f5fa, cornerRadius: 10, contentInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        button.tintColor = .a5a7bd
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        button.borderColor = .white
        button.borderWidth = 2
        button.touchAreaEdgeInsets = UIEdgeInsets(top: -24, left: -24, bottom: 0, right: 0)
        return button
    }()

    lazy var addBioButton = UIButton(height: 35,
                                     label: String(format: "%@ %@", "add".localized().uppercaseFirst, "bio".localized()),
                                     labelFont: .boldSystemFont(ofSize: 15),
                                     backgroundColor: .f3f5fa,
                                     textColor: .appMainColor,
                                     cornerRadius: 35/2)
    
    lazy var walletShadowView = UIView(forAutoLayout: ())
    lazy var walletView = UIView(cornerRadius: 16)
    lazy var communValueLabel = UILabel.with(text: "0", textSize: 20, weight: .semibold, textColor: .white)
    
    override func commonInit() {
        super.commonInit()
        
        // button
        addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        
        // add bio
        addSubview(addBioButton)
        
        // bind
        bind()
    }
    
    func bind() {
        descriptionLabel.rx.observe(String.self, "text")
            .map {$0?.isEmpty == false}
            .subscribe(onNext: { (shouldHide) in
                if shouldHide {
                    self.stackView.removeArrangedSubview(self.addBioButton)
                } else {
                    if !self.stackView.contains(self.addBioButton) {
                        self.stackView.insertArrangedSubview(self.addBioButton, at: 1)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func setUpStackView() {
        headerStackView.removeArrangedSubview(followButton)
        super.setUpStackView()
        
        walletShadowView.addSubview(walletView)
        walletView.autoPinEdgesToSuperviewEdges()
        
        setUpWalletView()
        
        stackView.insertArrangedSubview(walletShadowView, at: 2)
    }
    
    override func setUp(with profile: ResponseAPIContentGetProfile) {
        super.setUp(with: profile)
        communitiesLabel.attributedText = NSMutableAttributedString()
            .text("communities".localized().uppercaseFirst  + " " + "(\(profile.subscriptions?.communitiesCount ?? 0))", size: 20, weight: .bold)
    }
    
    func setUpWalletView(withError: Bool = false) {
        // clean
        walletView.removeSubviews()
        
        // layout
        if withError {
            let label = UILabel.with(text: "loading failed".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .white)
            walletView.addSubview(label)
            label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let retryButton = CommunButton.default(height: 35, label: "retry".localized().uppercaseFirst, cornerRadius: 35 / 2, isHuggingContent: true)
            retryButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            walletView.addSubview(retryButton)
            retryButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 16), excludingEdge: .leading)
        } else {
            let imageContainerView: UIView = {
                let imageView = UIImageView(width: 19.69 * Config.widthRatio, height: 18.05 * Config.widthRatio)
                imageView.image = UIImage(named: "wallet-icon")
                
                let imageContainerView = UIView(width: 50 * Config.widthRatio, height: 50 * Config.widthRatio, backgroundColor: UIColor.white.withAlphaComponent(0.2), cornerRadius: 25 * Config.widthRatio)
                imageContainerView.addSubview(imageView)
                imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
                imageView.autoAlignAxis(toSuperviewAxis: .vertical)
                return imageContainerView
            }()
            
            walletView.addSubview(imageContainerView)
            imageContainerView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            imageContainerView.topAnchor.constraint(greaterThanOrEqualTo: walletView.topAnchor, constant: 16)
                .isActive = true
            imageContainerView.bottomAnchor.constraint(lessThanOrEqualTo: walletView.bottomAnchor, constant: -16)
                .isActive = true
            
            // commun value
            let communValueContainerView: UIView = {
                let containerView = UIView(forAutoLayout: ())
                let equityCommunValueLabel = UILabel.with(text: "equity Commun Value".localized().uppercaseFirst, textSize: 12 * Config.widthRatio, weight: .semibold, textColor: .white, numberOfLines: 0)
                containerView.addSubview(equityCommunValueLabel)
                equityCommunValueLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
                
                containerView.addSubview(self.communValueLabel)
                self.communValueLabel.autoPinEdge(.top, to: .bottom, of: equityCommunValueLabel, withOffset: 4)
                self.communValueLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
                
                return containerView
            }()
            
            walletView.addSubview(communValueContainerView)
            communValueContainerView.autoPinEdge(.leading, to: .trailing, of: imageContainerView, withOffset: 10)
            communValueContainerView.autoAlignAxis(toSuperviewAxis: .horizontal)
            communValueContainerView.topAnchor.constraint(greaterThanOrEqualTo: walletView.topAnchor, constant: 16)
                .isActive = true
            communValueContainerView.bottomAnchor.constraint(lessThanOrEqualTo: walletView.bottomAnchor, constant: -16)
                .isActive = true
            
            let nextView: UIView = {
                let view = UIView(height: 35, backgroundColor: UIColor.white.withAlphaComponent(0.1), cornerRadius: 35 / 2)
                
                let label = UILabel.with(text: "wallet".localized().uppercaseFirst, textSize: 15 * Config.widthRatio, weight: .medium, textColor: .white)
                label.setContentHuggingPriority(.required, for: .horizontal)
                view.addSubview(label)
                label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16 * Config.widthRatio)
                label.autoAlignAxis(toSuperviewAxis: .horizontal)
                
                let nextArrow = UIImageView(width: 7.5, height: 15, imageNamed: "next-arrow")
                nextArrow.tintColor = .white
                view.addSubview(nextArrow)
                nextArrow.autoAlignAxis(toSuperviewAxis: .horizontal)
                nextArrow.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10 * Config.widthRatio)
                nextArrow.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16 * Config.widthRatio)
                
                return view
            }()
            
            walletView.addSubview(nextView)
            nextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            nextView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            nextView.autoPinEdge(.leading, to: .trailing, of: communValueContainerView, withOffset: 4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if walletView.frame != .zero {
            // gradient
            let gradient = CAGradientLayer()
            gradient.frame = walletView.bounds
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0, y: 0.5)
            gradient.colors = [UIColor(hexString: "#6A80F5")!.cgColor, UIColor(hexString: "#A4B1F9")!.cgColor]
            walletView.layer.insertSublayer(gradient, at: 0)
            
            // corner radius
            walletView.cornerRadius = 16
            
            // shadow
            walletShadowView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 24, offset: CGSize(width: 0, height: 14), opacity: 0.4)
        }
    }
}
