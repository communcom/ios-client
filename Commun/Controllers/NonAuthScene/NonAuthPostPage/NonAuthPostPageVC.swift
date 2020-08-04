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
    
    override func createCommentForm() -> CommentForm {
        NonAuthCommentForm(backgroundColor: .appWhiteColor)
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
