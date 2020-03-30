//
//  CommentsViewController+Actions.swift
//  Commun
//
//  Created by Chung Tran on 12/16/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension CommentsViewController {
    @objc func handleLongPressOnTableView(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point),
            let comment = commentAtIndexPath(indexPath),
            let currentCell = tableView.cellForRow(at: indexPath) as? CommentCell
        else {return}
        
        switch gesture.state {
        case .began:
            currentCell.contentTextView.backgroundColor = .lightGray
        case .ended:
            if (comment.sendingState ?? MessageSendingState.none) != MessageSendingState.none ||
                comment.document == nil {
                return
            }
            cell(currentCell, didTapMoreActionFor: comment)
            currentCell.contentTextView.backgroundColor = currentCell.contentTextViewBackgroundColor
        default:
            currentCell.contentTextView.backgroundColor = currentCell.contentTextViewBackgroundColor
        }
    }
}
