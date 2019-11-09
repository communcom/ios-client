//
//  CommentsViewController+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let parentComment = viewModel.items.value[section]
        
        // if all comments was fetched
        if parentComment.childCommentsCount + 1 == tableView.numberOfRows(inSection: section) {
            return nil
        }
        
        // count comments left
        let commentsLeft = Int(parentComment.childCommentsCount) - tableView.numberOfRows(inSection: section) + 1
        
        // show number of comments left
        let button = UIButton(label: "• \(commentsLeft) " + "replies".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
        
        let view = UIView(frame: .zero)
        view.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .leading, withInset: 62)
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let parentComment = viewModel.items.value[section]
        
        // if all comments was fetched
        if parentComment.childCommentsCount + 1 == tableView.numberOfRows(inSection: section) {
            return 0
        }
        
        return 30
    }
}
