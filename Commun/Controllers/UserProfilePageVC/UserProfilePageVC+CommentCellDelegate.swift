//
//  UserProfilePageVC+CommentCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UserProfilePageVC {
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment) {
        //TODO: delete comment
    }
    
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment) {
        //TODO: edit comment
    }
    
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        //TODO: replying
//        replyingComment = comment
    }
    
    func cell(_ cell: CommentCell, didTapRetryForComment comment: ResponseAPIContentGetComment) {
        // do nothing
    }
}
