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
    var upVoteButton: UIButton! {get set}
    var downVoteButton: UIButton! {get set}
    var comment: ResponseAPIContentGetComment? {get set}
    func setUp(with comment: ResponseAPIContentGetComment?)
}

extension ResponseAPIContentGetComment {
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(ResponseAPIContentGetComment.self)DidChange"), object: self)
    }
    
    public func notifyDeleted() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)Deleted"), object: self)
    }
}

extension CommentController {
    func observeCommentChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetComment.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newComment = notification.object as? ResponseAPIContentGetComment,
                    newComment.identity == self.comment?.identity
                    else {return}
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
        
        // animate
        animateUpVote {
            // notify
            self.comment!.notifyChanged()
            
            // disable button until transaction is done
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            
            // send request
            NetworkService.shared.voteMessage(voteType:          originHasUpVote ? .unvote: .upvote,
                                              messagePermlink:   comment.contentId.permlink,
                                              messageAuthor:     comment.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable buttons
                        self?.upVoteButton.isEnabled = true
                        self?.downVoteButton.isEnabled = true
                    },
                    onError: {[weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.comment!.notifyChanged()
                        
                        // re-enable buttons
                        strongSelf.upVoteButton.isEnabled = true
                        strongSelf.downVoteButton.isEnabled = true
                        
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
        
        // animate
        animateDownVote {
            // notify
            self.comment!.notifyChanged()
            
            // disable button until transaction is done
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            
            // send request
            NetworkService.shared.voteMessage(voteType:          originHasDownVote ? .unvote: .downvote,
                                              messagePermlink:   comment.contentId.permlink,
                                              messageAuthor:     comment.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable buttons
                        self?.upVoteButton.isEnabled = true
                        self?.downVoteButton.isEnabled = true
                    },
                    onError: { [weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.comment!.notifyChanged()
                        
                        // re-enable buttons
                        strongSelf.upVoteButton.isEnabled = true
                        strongSelf.downVoteButton.isEnabled = true
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func deleteComment() {
        guard let comment = comment,
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
                    #warning("delete comment")
//                    NetworkService.shared.deletePost(permlink: comment.contentId.permlink)
//                    .subscribe(onCompleted: {
//                        self.comment?.notifyChanged()
//                    }, onError: { error in
//                        topController.showError(error)
//                    })
//                    .disposed(by: self.disposeBag)
                }
            }
    }
    
    func editPost() {
        guard let comment = comment,
            let topController = UIApplication.topViewController() else {return}
        
        topController.showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
        #warning("delete comment")
//        NetworkService.shared.getPost(withPermLink: post.contentId.permlink)
//            .subscribe(onSuccess: {post in
//                topController.hideHud()
//                if post.document?.attributes?.type == "basic" {
//                    let vc = BasicEditorVC()
//                    vc.viewModel.postForEdit = post
//                    vc.modalPresentationStyle = .fullScreen
//                    topController.present(vc, animated: true, completion: nil)
//                    return
//                }
//
//                if post.document?.attributes?.type == "article" {
//                    let vc = ArticleEditorVC()
//                    vc.viewModel.postForEdit = post
//                    vc.modalPresentationStyle = .fullScreen
//                    topController.present(vc, animated: true, completion: nil)
//                    return
//                }
//                topController.hideHud()
//                topController.showError(ErrorAPI.invalidData(message: "Unsupported type of post"))
//            }, onError: {error in
//                topController.hideHud()
//                topController.showError(error)
//            })
//            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation
    func animateUpVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
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
    
    func animateDownVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
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


