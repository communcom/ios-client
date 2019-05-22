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

protocol PostController: class {
    var disposeBag: DisposeBag {get}
    var upVoteButton: UIButton! {get set}
    var downVoteButton: UIButton! {get set}
    var post: ResponseAPIContentGetPost? {get set}
    func setUp(with post: ResponseAPIContentGetPost?)
}

extension PostController {
    
    func notifyPostChange(newPost: ResponseAPIContentGetPost) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PostControllerPostDidChangeNotification), object: newPost)
    }
    
    func observePostChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newPost = notification.object as? ResponseAPIContentGetPost,
                    newPost.contentId.permlink != self.post?.contentId.permlink,
                    newPost == self.post
                    else {return}
                self.setUp(with: newPost)
            })
            .disposed(by: disposeBag)
    }
    
    func setHasVote(_ value: Bool, for type: VoteType) {
        guard let post = post else {return}
        
        // return if nothing changes
        if type == .upvote && value == post.votes.hasUpVote {return}
        if type == .downvote && value == post.votes.hasDownVote {return}
        
        // Image names
        let unselectedImage = type == .upvote ? "Up": "Down"
        let selectedImage = unselectedImage + "Selected"
        
        // set image
        let newImage = value ? selectedImage: unselectedImage
        
        if type == .upvote {
            upVoteButton.setImage(UIImage(named: newImage), for: .normal)
            self.post!.votes.hasUpVote = !self.post!.votes.hasUpVote
        }
        
        if type == .downvote {
            downVoteButton.setImage(UIImage(named: newImage), for: .normal)
            self.post!.votes.hasDownVote = !self.post!.votes.hasDownVote
        }
    }
    
    func openMorePostActions() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        var actions = [UIAlertAction]()
        
        if post.author?.userId == Config.currentUser.nickName {
            actions += [
                UIAlertAction(title: "Edit".localized(), style: .default, handler: { (_) in
                    topController.showAlert(title: "TODO", message: "Edit post")
                }),
                UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { (_) in
                    topController.showAlert(title: "TODO", message: "Delete post")
                })
            ]
        }
        
        actions.append(
            UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
                topController.showAlert(title: "TODO", message: "Report post")
            })
        )
        
        topController.showActionSheet(title: nil, message: nil, actions: actions)
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
    
    func sharePost() {
        guard let post = post,
            let userId = post.author?.userId,
            let controller = UIApplication.topViewController()
            else {return}
        // text to share
        var text = post.content.title + "\n"
        
        #warning("refBlockNum is being removed")
        text += "https://commun.com/posts/\(userId)/\(post.contentId.refBlockNum)/\(post.contentId.permlink)"
        
        
        // link to share
        let textToShare = [text]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        
        // present the view controller
        controller.present(activityViewController, animated: true, completion: nil)
    }

}
