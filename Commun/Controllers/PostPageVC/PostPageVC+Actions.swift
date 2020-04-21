//
//  PostPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 4/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension PostPageVC: PostCellDelegate, PostHeaderViewDelegate {
    // MARK: - Actions
    @objc func openMorePostActions() {
        guard let post = post else {return}
        menuButtonDidTouch(post: post)
    }
    
    @objc func sortButtonDidTouch() {
        showCommunActionSheet(
            title: "sort by".localized().uppercaseFirst,
            actions: [
                CommunActionSheet.Action(
                    title: "interesting first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .popularity)
                    }),
                CommunActionSheet.Action(
                    title: "newest first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .timeDesc)
                    }),
                CommunActionSheet.Action(
                    title: "oldest first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .time)
                    })
            ])
    }
    
    func headerViewUpVoteButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        upvoteButtonDidTouch(post: post)
    }
    
    func headerViewDownVoteButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        downvoteButtonDidTouch(post: post)
    }
    
    func headerViewShareButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        ShareHelper.share(post: post)
    }
    
    func headerViewCommentButtonDidTouch(_ headerView: PostHeaderView) {
        tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
