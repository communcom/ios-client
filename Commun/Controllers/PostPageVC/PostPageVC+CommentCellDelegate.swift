//
//  PostPageVC+CommentCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension UIViewController: CommentCellDelegate {
    
    func cell(_ cell: CommentCellProtocol, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .upvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "",
                                          refBlockNum: comment.contentId.refBlockNum)
    }
    
    func cell(_ cell: CommentCellProtocol, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .downvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "",
                                          refBlockNum: comment.contentId.refBlockNum)
    }
    
    func cell(_ cell: CommentCellProtocol, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Reply comment")
    }
    
}
