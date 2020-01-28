//
//  PostCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostCell {
    @objc func menuButtonTapped(button: UIButton) {
        guard let post = post else {return}
        self.delegate?.menuButtonDidTouch(post: post)
    }
    
    @objc func upVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        voteContainerView.animateUpVote {
            self.delegate?.upvoteButtonDidTouch(post: post)
        }
    }
    
    @objc func downVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        voteContainerView.animateDownVote {
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
    
    @objc func stateButtonTapped(_ sender: UIButton) {
        let postLink = sender.tag == 0 ? "https://dev.commun.com/" : "https://golos.io"
        let userNameRulesView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 355.0), height: CGFloat.adaptive(height: 193.0))), andParameters: sender.tag == 0 ? .topState : .rewardState)
        
        let cardVC = CardViewController(contentView: userNameRulesView)
        parentViewController?.present(cardVC, animated: true, completion: nil)
        
        userNameRulesView.completionDismissWithAction = {
            self.parentViewController?.dismiss(animated: true, completion: {
                if let baseVC = self.parentViewController as? BaseViewController {
                    baseVC.load(url: postLink)
                }
            })
        }
    }
}
