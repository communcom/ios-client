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
        if donationView is DonationUsersView {
            post?.showDonator = false
            post?.notifyChanged()
        }
        
        if donationView is DonationView {
            post?.showDonationButtons = false
            post?.notifyChanged()
        }
    }
    
    func headerView(_ headerView: PostHeaderView, donationUsersViewDidTouch donationUsersView: DonationUsersView) {
        guard let donations = post?.donations else {return}
        let vc = DonationsVC(donations: donations)
        vc.modelSelected = {donation in
            vc.dismiss(animated: true) {
                self.showProfileWithUserId(donation.sender.userId)
            }
        }

        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = vc
        present(navigation, animated: true, completion: nil)
    }
    
    func postStatsView(_ postStatsView: PostStatsView, didTapOnDonationCountLabel donationCountLabel: UIView) {
        var post = self.post
        if post?.showDonator == nil {post?.showDonator = false}
        post?.showDonator?.toggle()
        post?.notifyChanged()
    }
}
