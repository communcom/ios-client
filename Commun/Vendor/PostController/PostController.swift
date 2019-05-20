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

protocol PostController: class {
    var disposeBag: DisposeBag {get}
    var upVoteButton: UIButton! {get set}
    var downVoteButton: UIButton! {get set}
    var post: ResponseAPIContentGetPost? {get set}
}

extension PostController {
    
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
        topController.showAlert(title: "TODO", message: "Нажата кнопка контекстного меню")
    }
    
    func upVote() {
        guard let post = post else {return}
        
        // save original state
        let originHasUpVote = post.votes.hasUpVote
        let originHasDownVote = post.votes.hasDownVote
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        
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
        let title = post.content.title
        
        #warning("refBlockNum is being removed")
        let link = "https://commun.com/posts/\(userId)/\(post.contentId.refBlockNum)/\(post.contentId.permlink)"
        
        
        // link to share
        let textToShare = [title, link]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        
        // present the view controller
        controller.present(activityViewController, animated: true, completion: nil)
    }

}
