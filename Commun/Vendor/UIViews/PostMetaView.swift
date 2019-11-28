//
//  PostTitleView.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SwiftTheme

class PostMetaView: MyView {
    // MARK: - Enums
    class TapGesture: UITapGestureRecognizer {
        var post: ResponseAPIContentGetPost!
    }
    
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 40)
    lazy var comunityNameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var byUserLabel = UILabel.with(textSize: 13, weight: .semibold, textColor: .appMainColor)
    lazy var timeAgoLabel = UILabel()
    

    // MARK: - Properties
    var isUserNameTappable = true
    var isCommunityNameTappable = true
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        // avatar
        addSubview(avatarImageView)
        avatarImageView.autoPinTopAndLeadingToSuperView()
        
        // communityNameLabel
        addSubview(comunityNameLabel)
        comunityNameLabel.autoPinEdge(.top, to: .top, of: avatarImageView)
        comunityNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 8)
        comunityNameLabel.autoPinEdge(toSuperviewEdge: .trailing)
        comunityNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // timeAgoLabel
        timeAgoLabel.tune(withText:         "",
                          hexColors:        grayishBluePickers,
                          font:             UIFont(name: "SFProText-Semibold", size: CGFloat.adaptive(width: 12.0)),
                          alignment:        .left,
                          isMultiLines:     false)
        
        addSubview(timeAgoLabel)
        timeAgoLabel.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: -3)
        timeAgoLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 8)
        
        // byUserLabel
        addSubview(byUserLabel)
        byUserLabel.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: -3)
        byUserLabel.autoPinEdge(.leading, to: .trailing, of: timeAgoLabel)
        byUserLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        byUserLabel.removeGestureRecognizers()
        
        comunityNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            .isActive = true
        byUserLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            .isActive = true
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        avatarImageView.setAvatar(urlString: post.community.avatarUrl, namePlaceHolder: post.community.name)
        comunityNameLabel.text = post.community.name
        timeAgoLabel.text = Date.timeAgo(string: post.meta.creationTime) + " • "
        byUserLabel.text = post.author?.username ?? post.author?.userId
        
        // add gesture
        if isUserNameTappable {
            let tap = TapGesture(target: self, action: #selector(userNameTapped(_:)))
            tap.post = post
            byUserLabel.isUserInteractionEnabled = true
            byUserLabel.addGestureRecognizer(tap)
        }
        
        if isCommunityNameTappable {
            let tapLabel = TapGesture(target: self, action: #selector(communityNameTapped(_:)))
            let tapAvatar = TapGesture(target: self, action: #selector(communityNameTapped(_:)))
            tapLabel.post = post
            tapAvatar.post = post

            avatarImageView.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(tapAvatar)
            comunityNameLabel.isUserInteractionEnabled = true
            comunityNameLabel.addGestureRecognizer(tapLabel)

        }
    }
    
    @objc func userNameTapped(_ sender: TapGesture) {
        guard let userId = sender.post.author?.userId else {return}
        parentViewController?.showProfileWithUserId(userId)
    }
    
    @objc func communityNameTapped(_ sender: TapGesture) {
        let communityId = sender.post.community.communityId
        parentViewController?.showCommunityWithCommunityId(communityId)
    }
}
