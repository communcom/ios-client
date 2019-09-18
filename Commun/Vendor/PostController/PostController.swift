//
//  FeedPageVC+PostCardCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

let PostControllerPostDidChangeNotification = "PostControllerPostDidChangeNotification"
let PostControllerPostDidDeleteNotification = "PostControllerPostDidDeleteNotification"

protocol PostController: class {
    var disposeBag: DisposeBag {get}
    var upVoteButton: UIButton! {get set}
    var downVoteButton: UIButton! {get set}
    var post: ResponseAPIContentGetPost? {get set}
    func setUp(with post: ResponseAPIContentGetPost?)
}

extension PostController {
    // MARK: - Notify observers
    func notifyPostChange(newPost: ResponseAPIContentGetPost) {
        newPost.notifyChanged()
    }
    
    func notifyPostDeleted(deletedPost: ResponseAPIContentGetPost) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PostControllerPostDidDeleteNotification), object: deletedPost)
    }
    
    func observePostChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newPost = notification.object as? ResponseAPIContentGetPost,
                    newPost == self.post
                    else {return}
                self.setUp(with: newPost)
            })
            .disposed(by: disposeBag)
    }
    
    func openMorePostActions() {
        guard let topController = UIApplication.topViewController() else {return}
        
        var actions = [UIAlertAction]()
        
        if post?.author?.userId == Config.currentUser?.id {
            actions += [
                UIAlertAction(title: "edit".localized().uppercaseFirst, style: .default, handler: { (_) in
                    self.editPost()
                }),
                UIAlertAction(title: "delete".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                    self.deletePost()
                })
            ]
        } else {
            actions.append(
                UIAlertAction(title: "report".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                    self.reportPost()
                })
            )
        }
        
        topController.showActionSheet(title: nil, message: nil, actions: actions)
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let post = post else {return}
        
        // return if nothing changes
        if type == .upvote && value == post.votes.hasUpVote {return}
        if type == .downvote && value == post.votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !self.post!.votes.hasUpVote
            self.post!.votes.hasUpVote = voted
            self.post!.votes.upCount = (self.post?.votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let downVoted = !self.post!.votes.hasDownVote
            self.post!.votes.hasDownVote = downVoted
            self.post!.votes.downCount = (self.post?.votes.downCount ?? 0) + (downVoted ? 1: -1)
        }
    }
    
    func upVote() {
        guard let post = post else {return}
        
        // save original state
        let originHasUpVote = post.votes.hasUpVote
        let originHasDownVote = post.votes.hasDownVote
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        
        // animate
        animateUpVote()
        
        // notify
        notifyPostChange(newPost: self.post!)
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType:          originHasUpVote ? .unvote: .upvote,
                                          messagePermlink:   post.contentId.permlink,
                                          messageAuthor:     post.author?.userId ?? "")
            .subscribe(
                onCompleted: {
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                },
                onError: {error in
                    // reset state
                    self.setHasVote(originHasUpVote, for: .upvote)
                    self.setHasVote(originHasDownVote, for: .downvote)
                    self.notifyPostChange(newPost: self.post!)
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func downVote() {
        guard let post = post else {return}
        
        // save original state
        let originHasUpVote = post.votes.hasUpVote
        let originHasDownVote = post.votes.hasDownVote
        
        // change state
        setHasVote(originHasDownVote ? false: true, for: .downvote)
        setHasVote(false, for: .upvote)
        
        // animate
        animateDownVote()

        // notify
        notifyPostChange(newPost: self.post!)
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType:          originHasDownVote ? .unvote: .downvote,
                                          messagePermlink:   post.contentId.permlink,
                                          messageAuthor:     post.author?.userId ?? "")
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
                    self.notifyPostChange(newPost: self.post!)
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other actions
    func sharePost() {
        guard let post = post,
            let userId = post.author?.userId,
            let controller = UIApplication.topViewController()
            else {return}
        // text to share
        var text = post.content.title + "\n"
        
        text += "\(URL.appURL)/posts/\(userId)/\(post.contentId.permlink)"
        
        
        // link to share
        let textToShare = [text]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        
        // present the view controller
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
    func reportPost() {
        #warning("Report post")
    }
    
    func deletePost() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        NetworkService.shared.deletePost(permlink: post.contentId.permlink)
            .subscribe(onCompleted: {
                self.notifyPostDeleted(deletedPost: post)
            }, onError: { error in
                topController.showError(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func editPost() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        let viewModel = EditorPageViewModel()
        viewModel.postForEdit = post
        
        let vc = controllerContainer.resolve(EditorPageVC.self)!
        vc.viewModel = viewModel
        
        let nav = UINavigationController(rootViewController: vc)
        
        topController.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Commented
    func postDidComment() {
        guard post != nil else {return}
        self.post!.stats.commentsCount += 1
        notifyPostChange(newPost: self.post!)
    }

    // MARK: - Animation
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
