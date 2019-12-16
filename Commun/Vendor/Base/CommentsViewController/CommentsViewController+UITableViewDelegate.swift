//
//  CommentsViewController+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 12/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommentsViewController: UITableViewDelegate {
    func commentAtIndexPath(_ indexPath: IndexPath) -> ResponseAPIContentGetComment? {
        // root comment
        if indexPath.row == 0 {
            return viewModel.items.value[safe: indexPath.section]
        }
        
        return viewModel.items.value[safe: indexPath.section]?.children?[safe: indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let comment = commentAtIndexPath(indexPath),
            let height = viewModel.rowHeights[comment.identity]
        else {return UITableView.automaticDimension}
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let comment = commentAtIndexPath(indexPath)
        else {return 88}
        return viewModel.rowHeights[comment.identity] ?? 88
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let comment = commentAtIndexPath(indexPath)
        else {return}
        viewModel.rowHeights[comment.identity] = cell.bounds.height
    }
}
