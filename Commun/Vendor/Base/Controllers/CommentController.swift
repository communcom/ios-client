//
//  CommentController.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

protocol CommentController: class {
    var disposeBag: DisposeBag {get}
    var voteContainerView: VoteContainerView {get set}
    var comment: ResponseAPIContentGetComment? {get set}
    func setUp(with comment: ResponseAPIContentGetComment?)
}

extension ResponseAPIContentGetComment {
    static var childrenDidChangeEventName: String {"ChildrenDidChange"}
    
    public func notifyChildrenChanged() {
        notifyEvent(eventName: Self.childrenDidChangeEventName)
    }
}

extension CommentController {
    func observeCommentChange() {
        ResponseAPIContentGetComment.observeItemChanged()
            .subscribe(onNext: {newComment in
                self.setUp(with: newComment)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let comment = comment else {return}
        
        // return if nothing changes
        if type == .upvote && value == comment.votes.hasUpVote {return}
        if type == .downvote && value == comment.votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !(self.comment!.votes.hasUpVote ?? false)
            self.comment!.votes.hasUpVote = voted
            self.comment!.votes.upCount = (self.comment?.votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let downVoted = !(self.comment!.votes.hasDownVote ?? false)
            self.comment!.votes.hasDownVote = downVoted
            self.comment!.votes.downCount = (self.comment?.votes.downCount ?? 0) + (downVoted ? 1: -1)
        }
    }
    
    func upVote() {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote ?? false
        let originHasDownVote = comment.votes.hasDownVote ?? false
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        self.comment?.votes.isBeingVoted = true
        
        // animate
        voteContainerView.animateUpVote {
            // notify
            self.comment!.notifyChanged()
            
            // send request
            NetworkService.shared.voteMessage(voteType: originHasUpVote ? .unvote: .upvote,
                                              communityId: comment.community?.communityId ?? "",
                                              messagePermlink: comment.contentId.permlink,
                                              messageAuthor: comment.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable state
                        self?.comment?.votes.isBeingVoted = false
                        self?.comment?.notifyChanged()
                    },
                    onError: {[weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        self?.comment?.votes.isBeingVoted = false
                        strongSelf.comment!.notifyChanged()
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func downVote() {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote ?? false
        let originHasDownVote = comment.votes.hasDownVote ?? false
        
        // change state
        setHasVote(originHasDownVote ? false: true, for: .downvote)
        setHasVote(false, for: .upvote)
        self.comment?.votes.isBeingVoted = true
        
        // animate
        voteContainerView.animateDownVote {
            // notify
            self.comment!.notifyChanged()
            
            // disable button until transaction is done
            self.voteContainerView.upVoteButton.isEnabled = false
            self.voteContainerView.downVoteButton.isEnabled = false
            
            // send request
            NetworkService.shared.voteMessage(voteType: originHasDownVote ? .unvote: .downvote,
                                              communityId: comment.community?.communityId ?? "",
                                              messagePermlink: comment.contentId.permlink,
                                              messageAuthor: comment.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable state
                        self?.comment?.votes.isBeingVoted = false
                        self?.comment?.notifyChanged()
                    },
                    onError: { [weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        self?.comment?.votes.isBeingVoted = false
                        strongSelf.comment!.notifyChanged()
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func deleteComment() {
        guard let comment = comment,
            let communCode = comment.community?.communityId,
            let topController = UIApplication.topViewController() else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this comment".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1)
            { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting".localized().uppercaseFirst)
                    NetworkService.shared.deletePost(communCode: communCode, permlink: comment.contentId.permlink)
                        .subscribe(onCompleted: {
                            topController.hideHud()
                            self.comment?.notifyDeleted()
                        }, onError: { error in
                            topController.hideHud()
                            topController.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
    }
}


