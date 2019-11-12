//
//  PostPageNavigationBar.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class PostPageNavigationBar: MyView {
    lazy var backButton: UIButton = .back(tintColor: .a5a7bd)
    
    lazy var postMetaView: PostMetaView = {
        let view = PostMetaView(height: 40)
        return view
    }()
    
    lazy var joinButton = CommunButton.join
    
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
        joinButton.leadingAnchor.constraint(greaterThanOrEqualTo: postMetaView.trailingAnchor, constant: 8)
            .isActive = true
        
        postMetaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        postMetaView.setUp(post: post)
    }
    
    @objc func backButtonDidTouch() {
        parentViewController?.back()
    }
}
