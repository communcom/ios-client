//
//  PostPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 4/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension PostPageVC: PostHeaderViewDelegate, PostStatsViewDelegate {
    // MARK: - Actions
    @objc func openMorePostActions() {
        guard let post = post else {return}
        showPostMenu(post: post)
    }
    
    @objc func sortButtonDidTouch() {
        showCMActionSheet(
            title: "sort by".localized().uppercaseFirst,
            actions: [
                .default(
                    title: "interesting first".localized().uppercaseFirst,
                    showIcon: false,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .popularity)
                    }),
                .default(
                    title: "newest first".localized().uppercaseFirst,
                    showIcon: false,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .timeDesc)
                    }),
                .default(
                    title: "oldest first".localized().uppercaseFirst,
                    showIcon: false,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .time)
                    })
            ])
    }
    
    @objc func headerViewUpVoteButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        post.upVote()
            .subscribe { (error) in
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    @objc func headerViewDownVoteButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        post.downVote()
            .subscribe { (error) in
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func headerViewShareButtonDidTouch(_ headerView: PostHeaderView) {
        guard let post = post else {return}
        ShareHelper.share(post: post)
    }
    
    func headerViewCommentButtonDidTouch(_ headerView: PostHeaderView) {
        tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func headerViewDonationButtonDidTouch(_ headerView: PostHeaderView, amount: Double?) {
        guard let symbol = post?.community?.communityId,
            let post = post,
            let user = post.author
        else {return}

        let donateVC = WalletDonateVC(selectedBalanceSymbol: symbol, user: user, message: post, amount: amount)
        show(donateVC, sender: nil)
    }
    
    func headerViewDonationViewCloseButtonDidTouch(_ donationView: CMMessageView) {
        var post = self.post
        if donationView is DonationView {
            post?.showDonationButtons = false
            post?.notifyChanged()
        }
    }
}
