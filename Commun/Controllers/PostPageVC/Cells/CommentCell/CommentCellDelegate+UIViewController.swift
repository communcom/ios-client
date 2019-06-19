//
//  CommentCellDelegate+UIViewController.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol ViewControllerWithCommentCells: class {
    var expandedIndexes: [Int] {get set}
    var tableView: UITableView! {get set}
}

extension CommentCellDelegate where Self: UIViewController {
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .upvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .downvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Reply comment")
    }
}

extension CommentCellDelegate where Self: ViewControllerWithCommentCells {
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        expandedIndexes.append(indexPath.row)
        UIView.setAnimationsEnabled(false)
        tableView.reloadRows(at: [indexPath], with: .none)
        UIView.setAnimationsEnabled(true)
    }
}
