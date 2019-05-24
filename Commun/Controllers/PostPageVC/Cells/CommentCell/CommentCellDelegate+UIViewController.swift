//
//  CommentCellDelegate+UIViewController.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommentCellDelegate where Self: UIViewController {
    func cell(_ cell: CommentCellProtocol, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .upvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCellProtocol, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .downvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCellProtocol, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Reply comment")
    }
}
