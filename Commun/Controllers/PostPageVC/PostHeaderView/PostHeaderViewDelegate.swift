//
//  PostHeaderViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol PostHeaderViewDelegate: class {
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView)
    func didUpVotePost(_ post: ResponseAPIContentGetPost)
    func didDownVotePost(_ post: ResponseAPIContentGetPost)
    func sharePost(_ post: ResponseAPIContentGetPost)
}

extension PostHeaderViewDelegate where Self: UIViewController {
    func didUpVotePost(_ post: ResponseAPIContentGetPost) {
        showAlert(title: "Upvote", message: "TODO")
    }
    
    func didDownVotePost(_ post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Downvote")
    }
    
    func sharePost(_ post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Share")
    }
}
