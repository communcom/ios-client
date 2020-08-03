//
//  CommentCellController.swift
//  Commun
//
//  Created by Chung Tran on 12/2/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol CommentCellDelegate: class {
//    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedComments: [ResponseAPIContentGetComment] {get set}
    var tableView: UITableView {get set}
    var commentsListViewModel: ListViewModel<ResponseAPIContentGetComment> {get}
    func cell(_ cell: CommentCell, didTapUpVoteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapMoreActionFor comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapRetryForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnUserForComment comment: ResponseAPIContentGetComment)
}

extension CommentCellDelegate where Self: BaseViewController {
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if !expandedComments.contains(where: {$0.identity == comment.identity}) {
            expandedComments.append(comment)
        }
        commentsListViewModel.rowHeights[comment.identity] = nil
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func cell(_ cell: CommentCell, didTapOnUserName userName: String) {
        showProfileWithUserId(userName)
    }
    
    func cell(_ cell: CommentCell, didTapOnTag tag: String) {
        //TODO: open tag
    }
    
    func cell(_ cell: CommentCell, didTapMoreActionFor comment: ResponseAPIContentGetComment) {
        let headerView = UIView(frame: .zero)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let nameLabel = UILabel.with(textSize: 15, weight: .bold)
        headerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        var actions: [CommunActionSheet.Action] = []
        // parsing all paragraph
        var texts: [String] = []
       
        for documentContent in comment.document?.content.arrayValue ?? [] where documentContent.type == "paragraph" {
            if documentContent.content.arrayValue?.count ?? 0 > 0 {
                let paragraphContent = documentContent.content.arrayValue?.first
                
                if let text = paragraphContent?.content.stringValue {
                    texts.append(text)
                }
            }
        }

        // Add action `View in Explorer`
        if let trxID = comment.meta.trxId {
            actions.append(CommunActionSheet.Action(title: "view in Explorer".localized().uppercaseFirst,
                                                    handle: {
                                                        self.load(url: "https://explorer.cyberway.io/trx/\(trxID)")
            })
            )
        }
        
        if texts.count > 0 {
            actions.append(CommunActionSheet.Action(title: "copy".localized().uppercaseFirst,
                                                    icon: UIImage(named: "copy"),
                                                    tintColor: .appBlackColor,
                                                    handle: {
                                                        UIPasteboard.general.string = texts.joined(separator: "\n")
                                                        self.showDone("copied to clipboard".localized().uppercaseFirst)
                                                    })
            )
        }
        
        if comment.author?.userId == Config.currentUser?.id {
            actions.append(CommunActionSheet.Action(title: "edit".localized().uppercaseFirst,
                                                    icon: UIImage(named: "edit"),
                                                    tintColor: .appBlackColor,
                                                    handle: {
                                                        self.cell(cell, didTapEditForComment: comment)
                                                    })
            )
            
            actions.append(CommunActionSheet.Action(title: "delete".localized().uppercaseFirst,
                                                    icon: UIImage(named: "delete"),
                                                    tintColor: .appRedColor,
                                                    handle: {
                                                        self.deleteComment(comment)
                                                    })
            )
        } else {
            actions.append(CommunActionSheet.Action(title: "report".localized().uppercaseFirst,
                                                    icon: UIImage(named: "report"),
                                                    tintColor: .appRedColor,
                                                    handle: {
                                                        self.reportComment(comment)
                                                    })
            )
        }
        
        showCommunActionSheet(
            headerView: headerView,
            actions: actions,
            completion: {
                avatarImageView.setAvatar(urlString: comment.author?.avatarUrl)
                nameLabel.text = comment.author?.username
            })
    }
    
    func cell(_ cell: CommentCell, didTapUpVoteForComment comment: ResponseAPIContentGetComment) {
        // Prevent downvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            RequestsManager.shared.pendingRequests.append(.toggleLikeComment(comment: comment))
            nonAuthVC.showAuthVC()
            return
        }
        
        comment.upVote()
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func cell(_ cell: CommentCell, didTapDownVoteForComment comment: ResponseAPIContentGetComment) {
        // Prevent downvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            RequestsManager.shared.pendingRequests.append(.toggleLikeComment(comment: comment, dislike: true))
            nonAuthVC.showAuthVC()
            return
        }
        
        comment.downVote()
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func cell(_ cell: CommentCell, didTapOnUserForComment comment: ResponseAPIContentGetComment) {
        guard let userId = comment.author?.userId else {return}
        showProfileWithUserId(userId)
    }
    
    func reportComment(_ comment: ResponseAPIContentGetComment) {
        // Prevent reporting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            nonAuthVC.showAuthVC()
            return
        }
        
        let vc = ContentReportVC(content: comment)
        let nc = SwipeNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    func deleteComment(_ comment: ResponseAPIContentGetComment) {
        guard let topController = UIApplication.topViewController()
        else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this comment".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting comment".localized().uppercaseFirst)
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
