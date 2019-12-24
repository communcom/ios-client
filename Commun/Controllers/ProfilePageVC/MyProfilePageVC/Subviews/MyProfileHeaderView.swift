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

    lazy var addBioButton = UIButton(height: 35, label: "add bio".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .f3f5fa, textColor: .appMainColor, cornerRadius: 35/2)
    
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
        
        // actions
        let tap = UITapGestureRecognizer(target: self, action: #selector(walletDidTouch))
        walletView.isUserInteractionEnabled = true
        walletView.addGestureRecognizer(tap)
    }
    
    override func setUp(with profile: ResponseAPIContentGetProfile) {
        super.setUp(with: profile)
        communitiesCountLabel.text = nil
        communitiesLabel.text = "communities".localized().uppercaseFirst + " " + "(\(profile.subscriptions?.communitiesCount ?? 0))"
    }
    
    override func layoutFollowButton() {
        // remove followButton and set nameLabel as max width
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    override func layoutTopOfFollowerCountLabel() {
        // enquity value commun
        addSubview(walletShadowView)
        walletShadowView.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 16)
        walletShadowView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        walletShadowView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        walletShadowView.addSubview(walletView)
        walletView.autoPinEdgesToSuperviewEdges()
        
        let imageView = UIImageView(width: 9, height: 20)
        imageView.image = UIImage(named: "slash")
        
        let view = UIView(width: 50, height: 50, backgroundColor: UIColor.white.withAlphaComponent(0.2), cornerRadius: 25)
        view.addSubview(imageView)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        walletView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        let label = UILabel.with(text: "enquity Commun Value".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .white)
        walletView.addSubview(label)
        label.autoPinEdge(.leading, to: .trailing, of: view, withOffset: 10)
        label.autoPinEdge(.top, to: .top, of: view, withOffset: 4)
        
        walletView.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(.leading, to: .trailing, of: view, withOffset: 10)
        communValueLabel.autoPinEdge(.bottom, to: .bottom, of: view)
        
        let nextView: UIView = {
            let view = UIView(width: 35, height: 35, backgroundColor: UIColor.white.withAlphaComponent(0.1), cornerRadius: 35 / 2)
            let nextArrow = UIImageView(width: 9, height: 15, imageNamed: "next-arrow")
            nextArrow.tintColor = .white
            view.addSubview(nextArrow)
            nextArrow.autoAlignAxis(toSuperviewAxis: .horizontal)
            nextArrow.autoAlignAxis(toSuperviewAxis: .vertical)
            return view
        }()
        
        walletView.addSubview(nextView)
        nextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        nextView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        followersCountLabel.autoPinEdge(.top, to: .bottom, of: walletView, withOffset: 25)
    }
    
    override func setUpFollowButton(isFollowing: Bool) {
        // do nothing
    }

    private func configureAddBioButtonConstraints() {
        addBioButton.autoPinEdge(.top, to: .top, of: descriptionLabel)
        addBioButton.autoPinEdge(.leading, to: .leading, of: descriptionLabel)
        addBioButton.autoPinEdge(.trailing, to: .trailing, of: descriptionLabel)
        addBioButton.bottomAnchor.constraint(lessThanOrEqualTo: walletView.topAnchor, constant: -23)
            .isActive = true
    }
    
    func bind() {
        descriptionLabel.rx.observe(String.self, "text")
            .map {$0?.isEmpty == false}
            .subscribe(onNext: { (shouldHide) in
                if shouldHide {
                    self.addBioButton.isHidden = true
                    self.addBioButton.removeAllConstraints()
                } else {
                    self.addBioButton.isHidden = false
                    self.addBioButton.autoSetDimension(.height, toSize: 35)
                    self.configureAddBioButtonConstraints()
                }
            })
            .disposed(by: disposeBag)
    }
    
    var hasFixedWalletView = false
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasFixedWalletView, walletView.frame != .zero {
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
            hasFixedWalletView = true
        }
    }
    
    @objc func walletDidTouch() {
        let walletVC = WalletVC()
        parentViewController?.show(walletVC, sender: nil)
    }
}
