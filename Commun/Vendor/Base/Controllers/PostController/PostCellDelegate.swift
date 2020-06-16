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
}

extension PostCellDelegate where Self: BaseViewController {
    func postCell(_ postCell: PostCell, upvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    {
        guard let post = posts.first(where: {$0.identity == identity}) else {return}
        post.upVote()
            .subscribe { (error) in
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func postCell(_ postCell: PostCell, downvoteButtonDidTouchForPostWithIdentity identity: ResponseAPIContentGetPost.Identity)
    {
        guard let post = posts.first(where: {$0.identity == identity}) else {return}
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
}
