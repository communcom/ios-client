//
//  PostCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostCell {
    @objc func moreActionsButtonTapped() {
        guard let post = post else { return }
        
        self.delegate?.menuButtonDidTouch(post: post)
    }
    
    @objc func upVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        let hasUpVote = post.votes.hasUpVote ?? false
        postStatsView.voteContainerView.animateUpVote {
            self.delegate?.upvoteButtonDidTouch(post: post)
            DispatchQueue.main.async {
                if !hasUpVote {
                    self.showDonationButtons()
                }
            }
        }
    }
    
    @objc func downVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        postStatsView.voteContainerView.animateDownVote {
            self.delegate?.downvoteButtonDidTouch(post: post)
        }
    }

    @objc func shareButtonTapped(button: UIButton) {
        guard let post = post else { return }
        ShareHelper.share(post: post)
    }
    
    @objc func commentCountsButtonDidTouch() {
        guard let post = post else {return}
        
        let postPageVC = PostPageVC(post: post)
        postPageVC.scrollToTopAfterLoadingComment = true
        parentViewController?.show(postPageVC, sender: nil)
    }
    
    private func showDonationButtons() {
        if donationView.isDescendant(of: self) {
            donationView.removeFromSuperview()
            return
        }
        
        donationUsersView.removeFromSuperview()
        
        if Config.currentUser?.id == post?.author?.userId {return}
        
        addSubview(donationView)
        donationView.autoAlignAxis(toSuperviewAxis: .vertical)
        donationView.autoPinEdge(.bottom, to: .top, of: postStatsView, withOffset: -4)
        
        donationView.senderView = postStatsView.voteContainerView.likeCountLabel
    }
}
