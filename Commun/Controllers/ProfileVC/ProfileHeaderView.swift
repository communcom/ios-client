//
//  ProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ProfileHeaderView: UIView {
    // MARK: - Subviews
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: 210)
        imageView.cornerRadius = 24
        return imageView
    }()
    
    lazy var moreActionsButton: UIButton = {
        let button = UIButton(width: 20, height: 20)
        button.setImage(UIImage(named: "more"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        
//        button.addTarget(self, action: #selector(menuButtonTapped(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var changeCoverButton: UIButton = {
        let button = UIButton(width: 30, height: 30)
        button.cornerRadius = 15
        button.setImage(UIImage(named: "ProfilePageCoverCamera"), for: .normal)
        return button
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(width: 110, height: 110)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 55
        return imageView
    }()
    
    lazy var changeAvatarButton: UIButton = {
        let button = UIButton(width: 22, height: 22)
        button.cornerRadius = 11
        button.setImage(UIImage(named: "ProfilePageUserAvatarCamera"), for: .normal)
        return button
    }()
    
    lazy var userNameLabel = UILabel.with(text: "Sergey Marchenko", textSize: 20, weight: .bold)
    lazy var descriptionLabel = UILabel.descriptionLabel("Join on Mar 2017", size: 12)
    
    lazy var addBioButton: UIButton = {
        let button = UIButton(height: 40, label: "add bio".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#F3F5FA"), textColor: UIColor(hexString: "#6A80F5"), cornerRadius: 20)
        return button
    }()
    
    lazy var subscriptionsStackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        // followers
        let followersView = UIView(frame: .zero)
        
        let followersLabel = UILabel.descriptionLabel("followers".localized().uppercaseFirst, size: 12)
        followersLabel.textAlignment = .center
        followersView.addSubview(followersLabel)
        followersLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        followersView.addSubview(followersCountLabel)
        followersCountLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        followersCountLabel.autoPinEdge(.bottom, to: .top, of: followersLabel, withOffset: -5)
        followersCountLabel.textAlignment = .center
        
        // followings
        let followingsView = UIView(frame: .zero)
        
        let followingsLabel = UILabel.descriptionLabel("followings".localized().uppercaseFirst, size: 12)
        followingsLabel.textAlignment = .center
        followingsView.addSubview(followingsLabel)
        followingsLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        followingsView.addSubview(followingsCountLabel)
        followingsCountLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        followingsCountLabel.autoPinEdge(.bottom, to: .top, of: followingsLabel, withOffset: -5)
        followingsCountLabel.textAlignment = .center
        
        // my community
        let myCommunitiesView = UIView(frame: .zero)
        
        let myCommunitiesLabel = UILabel.descriptionLabel("my communities".localized().uppercaseFirst, size: 12)
        myCommunitiesLabel.textAlignment = .center
        myCommunitiesView.addSubview(myCommunitiesLabel)
        myCommunitiesLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        myCommunitiesView.addSubview(myCommunitiesCountLabel)
        myCommunitiesCountLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        myCommunitiesCountLabel.autoPinEdge(.bottom, to: .top, of: myCommunitiesLabel, withOffset: -5)
        myCommunitiesCountLabel.textAlignment = .center
        
        stackView.addArrangedSubviews([followersView, followingsView, myCommunitiesView])
        
        return stackView
    }()
    
    lazy var followersCountLabel = UILabel.with(text: "0", textSize: 24, weight: .bold)
    lazy var followingsCountLabel = UILabel.with(text: "0", textSize: 24, weight: .bold)
    lazy var myCommunitiesCountLabel = UILabel.with(text: "0", textSize: 24, weight: .bold)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        coverImageView.cornerRadius = 24
        
        addSubview(moreActionsButton)
        moreActionsButton.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        moreActionsButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -16)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        
        addSubview(avatarImageView)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        avatarImageView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: -55)
        
        addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: -4)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView, withOffset: -4)
        
        addSubview(userNameLabel)
        userNameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        userNameLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 16)
        
        addSubview(descriptionLabel)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 5)
        
        addSubview(addBioButton)
        addBioButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        addBioButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        addBioButton.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 20)
        
        addSubview(subscriptionsStackView)
        subscriptionsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        subscriptionsStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        subscriptionsStackView.autoPinEdge(.top, to: .bottom, of: addBioButton, withOffset: 16)
        subscriptionsStackView.autoSetDimension(.height, toSize: 62)
        
        let separatorView = UIView(height: 2, backgroundColor: UIColor(hexString: "#F3F5FA"))
        addSubview(separatorView)
        separatorView.autoPinEdge(.top, to: .bottom, of: subscriptionsStackView)
        separatorView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
}
