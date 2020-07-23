//
//  MyProfileEditGeneralInfoVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfileEditGeneralInfoVC {
    func reloadData() {
        // set cover
        coverImageView.setCover(urlString: profile?.coverUrl, namePlaceHolder: "cover-placeholder")
        
        // add views
        contentView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        // image wrappers
        let avatarWrapper = UIView(forAutoLayout: ())
        avatarWrapper.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges()
        avatarWrapper.addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        
        let coverWrapper = UIView(forAutoLayout: ())
        coverWrapper.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges()
        coverWrapper.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -16)
        
        stackView.addArrangedSubviews([
            avatarWrapper,
            coverWrapper
        ])
        
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0)
        
        stackView.setCustomSpacing(29, after: avatarWrapper)
    }
}
