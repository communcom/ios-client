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
                self.setUp(with: newComment)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Reporting
    func report() {
        guard let comment = comment else {return}
        let vc = ContentReportVC(content: comment)
        let nc = BaseNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    // MARK: - Voting
    func upVote() {
        guard let comment = comment else {return}
        // animate
        voteContainerView.animateUpVote {
            NetworkService.shared.upvoteMessage(message: comment)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func downVote() {
        guard let comment = comment else {return}
        // animate
        voteContainerView.animateDownVote {
            NetworkService.shared.downvoteMessage(message: comment)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
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
            highlightedButtonIndex: 1) { (index) in
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
