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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PostControllerPostDidChangeNotification), object: newPost)
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
        
        if post?.author?.userId == Config.currentUser.nickName {
            actions += [
                UIAlertAction(title: "Edit".localized(), style: .default, handler: { (_) in
                    self.editPost()
                }),
                UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { (_) in
                    self.deletePost()
                })
            ]
        }
        
        actions.append(
            UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
                self.reportPost()
            })
        )
        
        topController.showActionSheet(title: nil, message: nil, actions: actions)
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let post = post else {return}
        
        // return if nothing changes
        if type == .upvote && value == post.votes.hasUpVote {return}
        if type == .downvote && value == post.votes.hasDownVote {return}
        
        if type == .upvote {
            self.post!.votes.hasUpVote = !self.post!.votes.hasUpVote
        }
        
        if type == .downvote {
            self.post!.votes.hasDownVote = !self.post!.votes.hasDownVote
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
        notifyPostChange(newPost: self.post!)
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        upVoteObserver(post)
            .subscribe(
                onCompleted: {
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                },
                onError: {_ in
                    // reset state
                    self.setHasVote(originHasUpVote, for: .upvote)
                    self.setHasVote(originHasDownVote, for: .downvote)
                    self.notifyPostChange(newPost: self.post!)
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showGeneralError()
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
        notifyPostChange(newPost: self.post!)
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        downVoteObserver(post)
            .subscribe(
                onCompleted: {
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                },
                onError: {_ in
                    // reset state
                    self.setHasVote(originHasUpVote, for: .upvote)
                    self.setHasVote(originHasDownVote, for: .downvote)
                    self.notifyPostChange(newPost: self.post!)
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showGeneralError()
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
        
        text += "https://commun.com/posts/\(userId)/\(post.contentId.permlink)"
        
        
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
        
        NetworkService.shared.deletePost(permlink: post.contentId.permlink, refBlockNum: post.contentId.refBlockNum ?? 0)
            .subscribe(onCompleted: {
                self.notifyPostDeleted(deletedPost: post)
            }, onError: { (_) in
                topController.showGeneralError()
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

}
