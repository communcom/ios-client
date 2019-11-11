//
//  CommentsVC+CommentCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommentsViewController {
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment) {
        #warning("delete comment")
    }
    
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment) {
        #warning("edit comment")
    }
}
