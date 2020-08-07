//
//  PostCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol PostCellDelegate: class {
    var posts: [ResponseAPIContentGetPost] {get}
    func postCell(_ postCell: PostCell, upvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    func postCell(_ postCell: PostCell, downvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    func postCell(_ postCell: PostCell, menuButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    func postCell(_ postCell: PostCell, commentButtonDidTouchForPost post: ResponseAPIContentGetPost)
}

extension PostCellDelegate where Self: BaseViewController {
    func postCell(_ postCell: PostCell, upvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    {
        guard let post = posts.first(where: {$0.identity == identity}) else {return}
        // Prevent upvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
//            RequestsManager.shared.pendingRequests.append(.)
            RequestsManager.shared.pendingRequests.append(.toggleLikePost(post: post))
            nonAuthVC.showAuthVC()
            return
        }
        
        // Hide all donation buttons
        for var post in posts where post.showDonationButtons == true {
            post.showDonationButtons = false
            post.notifyChanged()
        }
        
        // Upvote and show donations buttons
        post.upVote()
            .subscribe { (error) in
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func postCell(_ postCell: PostCell, downvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    {
        guard let post = posts.first(where: {$0.identity == identity}) else {return}
        
        // Prevent downvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            RequestsManager.shared.pendingRequests.append(.toggleLikePost(post: post, dislike: true))
            nonAuthVC.showAuthVC()
            return
        }
        
        post.downVote()
            .subscribe { (error) in
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func postCell(_ postCell: PostCell, menuButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    {
        guard let post = posts.first(where: {$0.identity == identity}) else {return}
        showPostMenu(post: post)
    }
    
    func postCell(_ postCell: PostCell, commentButtonDidTouchForPost post: ResponseAPIContentGetPost) {
        
        let vc: PostPageVC
        if self is NonAuthVCType {
            vc = NonAuthPostPageVC(post: post)
        } else {
            vc = PostPageVC(post: post)
        }
        
        vc.scrollToTopAfterLoadingComment = true
        show(vc, sender: nil)
    }
}
