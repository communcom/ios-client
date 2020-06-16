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
        guard let postIdentity = postIdentity else { return }
        
        self.delegate?.postCell(self, menuButtonDidTouchForPostWithIdentity: postIdentity)
    }
    
    @objc func upVoteButtonTapped(button: UIButton) {
        guard let postIdentity = postIdentity else { return }
        postStatsView.voteContainerView.animateUpVote {
            self.delegate?.postCell(self, upvoteButtonDidTouchForPostWithIdentity: postIdentity)
        }
    }
    
    @objc func downVoteButtonTapped(button: UIButton) {
        guard let postIdentity = postIdentity else { return }
        postStatsView.voteContainerView.animateDownVote {
            self.delegate?.postCell(self, downvoteButtonDidTouchForPostWithIdentity: postIdentity)
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
}
