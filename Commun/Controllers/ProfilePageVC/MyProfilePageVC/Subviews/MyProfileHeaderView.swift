//
//  MyProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

final class MyProfileHeaderView: UserProfileHeaderView {
    lazy var changeAvatarButton: UIButton = {
        let button = UIButton(width: 20, height: 20, backgroundColor: .f3f5fa, cornerRadius: 10, contentInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        button.tintColor = .a5a7bd
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        button.borderColor = .white
        button.borderWidth = 2
        return button
    }()
    
    lazy var addBioButton = UIButton(height: 35, label: "add bio".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .f3f5fa, textColor: .appMainColor, cornerRadius: 35/2)
    
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
    
    override func layoutFollowButton() {
        // remove followButton and set nameLabel as max width
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    override func setUpFollowButton(isFollowing: Bool) {
        // do nothing
    }

    private func configureAddBioButtonConstraints() {
        addBioButton.autoPinEdge(.top, to: .top, of: descriptionLabel)
        addBioButton.autoPinEdge(.leading, to: .leading, of: descriptionLabel)
        addBioButton.autoPinEdge(.trailing, to: .trailing, of: descriptionLabel)
        addBioButton.bottomAnchor.constraint(lessThanOrEqualTo: followersCountLabel.topAnchor, constant: -23)
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
}
