//
//  PostPageVC+CommentCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension PostPageVC: CommentCellDelegate {
    
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Upvote comment")
    }
    
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Downvote comment")
    }
    
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Reply comment")
    }
    
}
