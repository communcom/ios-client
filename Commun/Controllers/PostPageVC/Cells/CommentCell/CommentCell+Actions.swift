//
//  CommentCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 8/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import TTTAttributedLabel

extension CommentCell: TTTAttributedLabelDelegate {
    @objc func authorDidTouch(gesture: UITapGestureRecognizer) {
        guard let userId = comment?.author?.userId else {return}
        delegate?.cell(self, didTapOnUserName: userId)
    }
    
    @objc func contentLabelDidTouch(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text,
            let comment = comment
            else {return}
        
        let seeMoreRange = (text as NSString).range(of: "see more".localized().uppercaseFirst)
        
        if gesture.didTapAttributedTextInLabel(label: label, inRange: seeMoreRange) {
            delegate?.cell(self, didTapSeeMoreButtonForComment: comment)
            return
        }
        
//        for userName in text.getMentions() {
//            let range = (text as NSString).range(of: "@\(userName)")
//            if gesture.didTapAttributedTextInLabel(label: label, inRange: range) {
//                delegate?.cell(self, didTapOnUserName: userName)
//                return
//            }
//        }
//
//        for tag in text.getTags() {
//            let range = (text as NSString).range(of: "#\(tag)")
//            if gesture.didTapAttributedTextInLabel(label: label, inRange: range) {
//                delegate?.cell(self, didTapOnTag: tag)
//                return
//            }
//        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print(url)
    }
    
    
    
    @IBAction func replyButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapReplyButtonForComment: comment)
        }
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let comment = comment else {return}
        
        // return if nothing changes
        if type == .upvote && value == comment.votes.hasUpVote {return}
        if type == .downvote && value == comment.votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !self.comment!.votes.hasUpVote
            self.comment!.votes.hasUpVote = voted
            self.comment!.votes.upCount = (self.comment?.votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let voted = !self.comment!.votes.hasDownVote
            self.comment!.votes.hasDownVote = voted
            self.comment!.votes.downCount = (self.comment?.votes.downCount ?? 0) + (voted ? 1: -1)
        }
    }
    
    @IBAction func upVoteButtonTap(_ sender: Any) {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote
        let originHasDownVote = comment.votes.hasDownVote
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        
        // animation
        animateUpVote()
        
        // notify
        self.comment?.notifyChanged()
        
        // disable button ntil transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType: originHasUpVote ? .unvote: .upvote, messagePermlink: comment.contentId.permlink, messageAuthor: comment.author?.userId ?? "")
            .subscribe(onCompleted: {
                // re-enable buttons
                self.upVoteButton.isEnabled = true
                self.downVoteButton.isEnabled = true
            }) { (error) in
                // reset state
                self.setHasVote(originHasUpVote, for: .upvote)
                self.setHasVote(originHasDownVote, for: .downvote)
                self.comment?.notifyChanged()
                
                // re-enable buttons
                self.upVoteButton.isEnabled = true
                self.downVoteButton.isEnabled = true
                
                // show general error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: bag)
        
        delegate?.cell(self, didTapUpVoteButtonForComment: comment)
    }
    
    @IBAction func downVoteButtonTap(_ sender: Any) {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote
        let originHasDownVote = comment.votes.hasDownVote
        
        // change state
        setHasVote(originHasDownVote ? false: true, for: .downvote)
        setHasVote(false, for: .upvote)
        
        // animation
        animateDownVote()
        
        // notify
        self.comment?.notifyChanged()
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType:          originHasDownVote ? .unvote: .downvote,
                                          messagePermlink:   comment.contentId.permlink,
                                          messageAuthor:     comment.author?.userId ?? "")
            .subscribe(
                onCompleted: {
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
            },
                onError: { error in
                    // reset state
                    self.setHasVote(originHasUpVote, for: .upvote)
                    self.setHasVote(originHasDownVote, for: .downvote)
                    self.comment?.notifyChanged()
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: bag)
        
        delegate?.cell(self, didTapDownVoteButtonForComment: comment)
    }
    
    // MARK: - Animations
    func animateUpVote() {
        CATransaction.begin()
        
        let moveUpAnim = CABasicAnimation(keyPath: "position.y")
        moveUpAnim.byValue = -16
        moveUpAnim.autoreverses = true
        self.upVoteButton.layer.add(moveUpAnim, forKey: "moveUp")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.upVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
    
    func animateDownVote() {
        CATransaction.begin()
        
        let moveDownAnim = CABasicAnimation(keyPath: "position.y")
        moveDownAnim.byValue = 16
        moveDownAnim.autoreverses = true
        self.downVoteButton.layer.add(moveDownAnim, forKey: "moveDown")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.downVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
