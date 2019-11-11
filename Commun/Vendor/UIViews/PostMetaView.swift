//
//  PostTitleView.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class PostMetaView: UIView {
    // MARK: - Enums
    class TapGesture: UITapGestureRecognizer {
        var post: ResponseAPIContentGetPost!
    }
    
    // MARK: - Subviews
    lazy var avatarImageView: MyAvatarImageView = {
        let avatarImageView = MyAvatarImageView(size: 40)
        return avatarImageView
    }()

    lazy var comunityNameLabel: UILabel = {
        let comunityNameLabel = UILabel()
        comunityNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        comunityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return comunityNameLabel
    }()
    
    lazy var timeAgoLabel: UILabel = {
        let timeAgoLabel = UILabel()
        timeAgoLabel.font = .systemFont(ofSize: 13)
        timeAgoLabel.textColor = .lightGray
        timeAgoLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeAgoLabel
    }()
    
    lazy var byUserLabel: UILabel = {
        let byUserLabel = UILabel()
        byUserLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        byUserLabel.textColor = .appMainColor
        byUserLabel.translatesAutoresizingMaskIntoConstraints = false
        return byUserLabel
    }()
    
    // MARK: - Properties
    var isUserNameTappable = true
    var isCommunityNameTappable = true
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        // avatar
        addSubview(avatarImageView)
        avatarImageView.topAnchor
            .constraint(equalTo: topAnchor, constant: -1)
            .isActive = true
        avatarImageView.leadingAnchor
            .constraint(equalTo: leadingAnchor)
            .isActive = true
        avatarImageView.heightAnchor
            .constraint(equalTo: heightAnchor)
            .isActive = true
        avatarImageView.widthAnchor
            .constraint(equalTo: avatarImageView.heightAnchor)
            .isActive = true
        
        // communityNameLabel
        addSubview(comunityNameLabel)
        comunityNameLabel.topAnchor
            .constraint(equalTo: avatarImageView.topAnchor)
            .isActive = true
        comunityNameLabel
            .leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
            .isActive = true
        comunityNameLabel.trailingAnchor
            .constraint(equalTo: trailingAnchor)
            .isActive = true
        
        // timeAgoLabel
        addSubview(timeAgoLabel)
        
        timeAgoLabel.bottomAnchor
            .constraint(equalTo: avatarImageView.bottomAnchor, constant: -3)
            .isActive = true
        timeAgoLabel.leadingAnchor
            .constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
            .isActive = true
        
        // byUserLabel
        addSubview(byUserLabel)
        byUserLabel.bottomAnchor
            .constraint(equalTo: avatarImageView.bottomAnchor, constant: -3)
            .isActive = true
        byUserLabel.leadingAnchor
            .constraint(equalTo: timeAgoLabel.trailingAnchor, constant: 0)
            .isActive = true
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
