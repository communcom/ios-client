//
//  CommentsViewController+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 12/16/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let comment = itemAtIndexPath(indexPath),
            let height = viewModel.rowHeights[comment.identity]
        else {return UITableView.automaticDimension}
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let comment = itemAtIndexPath(indexPath)
        else {return 88}
        return viewModel.rowHeights[comment.identity] ?? 88
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard var comment = itemAtIndexPath(indexPath)
        else {return}
        viewModel.rowHeights[comment.identity] = cell.bounds.height
        
        // hide donation buttons when cell was removed
        if !tableView.isCellVisible(indexPath: indexPath), comment.showDonationButtons == true {
            comment.showDonationButtons = false
            comment.notifyChanged()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let parentComment = viewModel.items.value[safe: section] else { return nil }
        
        // if all comments was fetched
        if parentComment.childCommentsCount + 1 == tableView.numberOfRows(inSection: section) {
            return nil
        }
        
        // count comments left
        let commentsLeft = Int(parentComment.childCommentsCount) - tableView.numberOfRows(inSection: section) + 1
        
        if commentsLeft <= 0 {return nil}
        
        // show number of comments left
        let button = ReplyButton(label: "• \(commentsLeft) " + "replies".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 13), textColor: .appMainColor)
        button.parentComment = parentComment
        button.offset = UInt(parentComment.children?.count ?? 0)
        button.addTarget(self, action: #selector(repliesDidTouch(_:)), for: .touchUpInside)
        
        // Automatically disclose Reply comments
        self.repliesDidTouch(button)
        
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
        guard let post = (viewModel as! PostPageViewModel).post.value, let comment = button.parentComment else { return }
        
        let originTitle = button.titleLabel?.text
        button.setTitle("loading".localized().uppercaseFirst + "...", for: .normal)
        button.isEnabled = false
        
        (viewModel as! CommentsViewModel).getRepliesForComment(comment, inPost: post, offset: button.offset, limit: button.limit)
            .subscribe(onError: {[weak self] (error) in
                self?.showError(error)
                button.setTitle(originTitle, for: .normal)
                button.isEnabled = true
            })
            .disposed(by: disposeBag)
    }
}
