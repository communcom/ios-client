//
//  MyProfileEditCoverVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditCoverVC: BaseViewController {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var coverImage = UIImageView(imageNamed: "dankmeme_facebook")
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "change position".localized().uppercaseFirst
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        scrollView.widthAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 414 / 158)
            .isActive = true
        
        scrollView.contentView.addSubview(coverImage)
        coverImage.autoPinEdgesToSuperviewEdges()
        
        coverImage.heightAnchor.constraint(equalTo: coverImage.widthAnchor, multiplier: coverImage.image!.size.height / coverImage.image!.size.width)
            .isActive = true
        coverImage.widthAnchor.constraint(equalTo: view.widthAnchor)
            .isActive = true
        
        let dragToMoveTipView: UIView = {
            let view = UIView(backgroundColor: UIColor.black.withAlphaComponent(0.2), cornerRadius: 4)
            let imageView = UIImageView(width: 16, height: 16, imageNamed: "ProfilePageCoverDragIcon")
            view.addSubview(imageView)
            imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 12)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let label = UILabel.with(text: "drag to move cover photo".localized().uppercaseFirst, textSize: 15, textColor: .white)
            view.addSubview(label)
            label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 12), excludingEdge: .leading)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 6)
            return view
        }()
        view.addSubview(dragToMoveTipView)
        dragToMoveTipView.autoAlignAxis(.horizontal, toSameAxisOf: scrollView)
        dragToMoveTipView.autoAlignAxis(.vertical, toSameAxisOf: scrollView)
        
        let avatarImageView = MyAvatarImageView(size: 50)
        avatarImageView.setToCurrentUserAvatar()
        
        view.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(.top, to: .bottom, of: scrollView, withOffset: 16)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        let userNameLabel = UILabel.with(text: Config.currentUser?.name, textSize: 19, weight: .bold)
        view.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(.top, to: .top, of: avatarImageView)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        let joinDateLabel = UILabel.with(text: Formatter.joinedText(with: profile?.registration?.time), textSize: 12, weight: .semibold, textColor: .a5a7bd)
        view.addSubview(joinDateLabel)
        joinDateLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 4)
        joinDateLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
    }
}
