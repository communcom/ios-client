//
//  NonAuthPostPageVC.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthPostPageVC: PostPageVC, NonAuthVCType {
    override class var authorizationRequired: Bool {false}
    
    lazy var commentFormCoverView = UIView(forAutoLayout: ())
    
    override func setUp() {
        super.setUp()
        shadowView.addSubview(commentFormCoverView)
        commentFormCoverView.autoPinEdgesToSuperviewEdges()
        
        commentFormCoverView.isUserInteractionEnabled = true
        commentFormCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentFormCoverViewDidTouch)))
    }
    
    override func replyToComment(_ comment: ResponseAPIContentGetComment) {
        showAuthVC()
    }
    
    @objc func commentFormCoverViewDidTouch() {
        showAuthVC()
    }
}

extension NonAuthPostPageVC {
    override func headerViewUpVoteButtonDidTouch(_ headerView: PostHeaderView) {
        showAuthVC()
    }
    
    override func headerViewDownVoteButtonDidTouch(_ headerView: PostHeaderView) {
        showAuthVC()
    }
}
