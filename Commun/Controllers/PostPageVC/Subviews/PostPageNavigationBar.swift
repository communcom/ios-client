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
    lazy var backButton: UIButton = .back(tintColor: .a5a7bd, contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 15))
    
    lazy var postMetaView = PostMetaView(height: 40)
    
    lazy var moreButton: UIButton = {
        let button = UIButton(width: 36, height: 40, contentInsets: UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6))
        button.tintColor = .appGrayColor
        button.setImage(UIImage(named: "icon-post-cell-more-center-default"), for: .normal)
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
        moreButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        moreButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        moreButton.autoPinEdge(.leading, to: .trailing, of: postMetaView, withOffset: 8)

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
//        let joined = community.isSubscribed ?? false
//        joinButton.setHightLight(joined, highlightedLabel: "following", unHighlightedLabel: "follow")
//        joinButton.isEnabled = !(community.isBeingJoined ?? false)
    }
    
    @objc func backButtonDidTouch() {
        parentViewController?.back()
    }
    @objc func joinButtonDidTouch() {
        toggleJoin()
    }
}
