//
//  CommentCellDelegate+UIViewController.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension CommentCellDelegate where Self: UIViewController {
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
//        replyingComment = comment
    }
    
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        expandedIndexes.append(indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func cell(_ cell: CommentCell, didTapOnUserName userName: String) {
        showProfileWithUserId(userName)
    }
    
    func cell(_ cell: CommentCell, didTapOnTag tag: String) {
        #warning("open tag")
    }
}
