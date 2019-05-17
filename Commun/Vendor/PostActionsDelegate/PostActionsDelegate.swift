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

protocol PostActionsDelegate: class {
    var disposeBag: DisposeBag {get}
    var upVoteButton: UIButton! {get set}
    var downVoteButton: UIButton! {get set}
    var post: ResponseAPIContentGetPost? {get set}
}

extension PostActionsDelegate {
    
    func didTapMenuButton() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        topController.showAlert(title: "TODO", message: "Нажата кнопка контекстного меню")
    }
    
    func upVote() {
        guard let post = post else {return}
        let originImage = post.votes.hasUpVote ? "UpSelected" : "Up"
        let newImage = originImage == "Up" ? "UpSelected": "Up"
        upVoteButton.setImage(UIImage(named: newImage), for: .normal)
        var newPost = post
        newPost.votes.hasUpVote = !post.votes.hasUpVote
        self.post = newPost
        
        upVoteButton.isEnabled = false
        upVoteObserver(post)
            .subscribe(
                onCompleted: {
                    self.upVoteButton.isEnabled = true
                },
                onError: {_ in
                    UIApplication.topViewController()?.showGeneralError()
                    self.upVoteButton.setImage(UIImage(named: originImage), for: .normal)
                    self.upVoteButton.isEnabled = true
            })
            .disposed(by: disposeBag)
    }
    
    func downVote() {
        guard let post = post else {return}
        let originImage = post.votes.hasDownVote ? "DownSelected" : "Down"
        let newImage = originImage == "Down" ? "DownSelected": "Down"
        downVoteButton.setImage(UIImage(named: newImage), for: .normal)
        var newPost = post
        newPost.votes.hasDownVote = !post.votes.hasDownVote
        self.post = newPost
        
        downVoteButton.isEnabled = false
        downVoteObserver(post)
            .subscribe(
                onCompleted: {
                    self.downVoteButton.isEnabled = true
                },
                onError: {_ in
                    UIApplication.topViewController()?.showGeneralError()
                    self.downVoteButton.setImage(UIImage(named: originImage), for: .normal)
                    self.downVoteButton.isEnabled = true
            })
            .disposed(by: disposeBag)
    }
    
    func didTapShareButton() {
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
