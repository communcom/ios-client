//
//  CommentController.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

protocol CommentController: class {
    var disposeBag: DisposeBag {get}
    var voteContainerView: VoteContainerView {get set}
    var comment: ResponseAPIContentGetComment? {get set}
    func setUp(with comment: ResponseAPIContentGetComment)
}

extension CommentController {
    func observeCommentChange() {
        ResponseAPIContentGetComment.observeItemChanged()
            .filter {$0.identity == self.comment?.identity}
            .subscribe(onNext: {newComment in
                guard let newComment = self.comment?.newUpdatedItem(from: newComment) else {return}
                self.setUp(with: newComment)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Reporting
    func report() {
        guard let comment = comment else {return}
        let vc = ContentReportVC(content: comment)
        let nc = SwipeNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    // MARK: - Voting
    func upVote() {
        guard let comment = comment else {return}
        if comment.contentId.userId == Config.currentUser?.id {
            UIApplication.topViewController()?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        // animate
        voteContainerView.animateUpVote {
            BlockchainManager.instance.upvoteMessage(comment)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func downVote() {
        guard let comment = comment else {return}
        if comment.contentId.userId == Config.currentUser?.id {
            UIApplication.topViewController()?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        // animate
        voteContainerView.animateDownVote {
            BlockchainManager.instance.downvoteMessage(comment)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
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
            highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting".localized().uppercaseFirst)
                    BlockchainManager.instance.deleteMessage(comment)
                        .subscribe(onCompleted: {
                            topController.hideHud()
                        }, onError: { error in
                            topController.hideHud()
                            topController.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
    }
}
