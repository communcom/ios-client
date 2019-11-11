//
//  CommentsViewController+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension PostPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let parentComment = viewModel.items.value[section]
        
        // if all comments was fetched
        if parentComment.childCommentsCount + 1 == tableView.numberOfRows(inSection: section) {
            return nil
        }
        
        // count comments left
        let commentsLeft = Int(parentComment.childCommentsCount) - tableView.numberOfRows(inSection: section) + 1
        
        // show number of comments left
        let button = ReplyButton(label: "• \(commentsLeft) " + "replies".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
        button.parentComment = parentComment
        button.offset = UInt(parentComment.children?.count ?? 0)
        button.addTarget(self, action: #selector(repliesDidTouch(_:)), for: .touchUpInside)
        
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
    
    @objc func repliesDidTouch(_ button: ReplyButton) {
        guard let post = (viewModel as! PostPageViewModel).post.value,
            let comment = button.parentComment
        else {return}
        let originTitle = button.titleLabel?.text
        button.setTitle("loading".localized().uppercaseFirst + "...", for: .normal)
        button.isEnabled = false
        RestAPIManager.instance.getRepliesForComment(
            forPost: post.contentId,
            parentComment: comment.contentId,
            sortBy: .time,
            offset: button.offset,
            limit: button.limit,
            resolveNestedComments: true
        )
            .map {$0.items}
            .subscribe(onSuccess: {[weak self] (children) in
                guard let strongSelf = self else {return}
                // modify data
                var comments = strongSelf.viewModel.items.value
                if let currentCommentIndex = comments.firstIndex(where: {$0.identity == comment.identity})
                {
                    var newChildren = comments[currentCommentIndex].children ?? []
                    newChildren.joinUnique(children ?? [])
                    #warning("bug in backend, response comments returns all parents comment, delete filterOut after bug fixing")
                    comments[currentCommentIndex].children = newChildren.filterOut(comments)
                }
                strongSelf.viewModel.items.accept(comments)
            }) { [weak self] (error) in
                self?.showError(error)
                button.setTitle(originTitle, for: .normal)
                button.isEnabled = true
            }
            .disposed(by: disposeBag)
    }
}
