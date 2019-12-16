//
//  UserProfilePageVC+CommentCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UserProfilePageVC {
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment) {
        #warning("delete comment")
    }
    
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment) {
        #warning("edit comment")
    }
    
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        #warning("replying")
//        replyingComment = comment
    }
    
    func cell(_ cell: CommentCell, didTapRetryForComment comment: ResponseAPIContentGetComment) {
        // do nothing
    }
}
