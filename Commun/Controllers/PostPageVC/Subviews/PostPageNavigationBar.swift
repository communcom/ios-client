//
//  PostPageNavigationBar.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class PostPageNavigationBar: MyView, CommunityController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var community: ResponseAPIContentGetCommunity?
    
    // MARK: - Subviews
    lazy var backButton: UIButton = .back(tintColor: .a5a7bd)
    
    lazy var postMetaView: PostMetaView = {
        let view = PostMetaView(height: 40)
        return view
    }()
    
    lazy var joinButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    lazy var moreButton: UIButton = {
        let button = UIButton(width: 36, height: 40, contentInsets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        button.tintColor = .black
        button.setImage(UIImage(named: "postpage-more"), for: .normal)
        return button
    }()
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.autoPinEdge(toSuperviewEdge: .leading)
        backButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        backButton.addTarget(self, action: #selector(backButtonDidTouch), for: .touchUpInside)
        
        addSubview(postMetaView)
        postMetaView.autoPinEdge(.leading, to: .trailing, of: backButton)
        postMetaView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(moreButton)
        moreButton.autoPinEdge(toSuperviewEdge: .trailing)
        moreButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(joinButton)
        joinButton.autoPinEdge(.trailing, to: .leading, of: moreButton)
        joinButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        joinButton.autoPinEdge(.leading, to: .trailing, of: postMetaView, withOffset: 8)
        
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
        
//        postMetaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        joinButton.leadingAnchor.constraint(greaterThanOrEqualTo: postMetaView.trailingAnchor, constant: 8)
            .isActive = true
        
        observeCommunityChange()
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        guard let community = post.community else {return}
        postMetaView.setUp(post: post)
        setUp(with: community)
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.setHightLight(joined, highlightedLabel: "following", unHighlightedLabel: "follow")
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
    }
    
    @objc func backButtonDidTouch() {
        parentViewController?.back()
    }
    @objc func joinButtonDidTouch() {
        toggleJoin()
    }
}
