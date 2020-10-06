//
//  BaseViewController+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 6/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices

extension BaseViewController {
    func showPostMenu(post: ResponseAPIContentGetPost) {
        var actions = [CMActionSheet.Action]()
        actions.append(
            .default(
                title: "view in Explorer".localized().uppercaseFirst,
                showIcon: false,
                handle: { self.load(url: "https://explorer.cyberway.io/trx/\(post.meta.trxId ?? "")") }
            )
        )
        
        if let community = post.community, let isSubscribed = community.isSubscribed,
            !(self is NonAuthVCType)
        {
            let actionProperties = self.actionInfo(isSubscribed: isSubscribed)
            
            var action = CMActionSheet.Action.default(
                title: actionProperties.title,
                iconName: actionProperties.icon,
                handle: { self.handleFollowAction() }
            )
            
            action.id = "follow"
            action.dismissActionSheetOnCompleted = false
            action.associatedValue = community
            
            actions.append(action)
        }
        
        if post.author?.userId != Config.currentUser?.id {
            actions.append(
                .default(
                    title: "send report".localized().uppercaseFirst,
                    iconName: "report",
                    tintColor: .appRedColor,
                    handle: { self.reportPost(post) }
                )
            )
        } else {
            actions.append(
                .default(
                    title: "edit".localized().uppercaseFirst,
                    iconName: "edit",
                    handle: { self.editPost(post) }
                )
            )
        }
        
        actions.append(
            .default(
                title: "share".localized().uppercaseFirst,
                iconName: "share",
                handle: { ShareHelper.share(post: post) }
            )
        )

        if post.author?.userId == Config.currentUser?.id {
            actions.append(
                .default(
                    title: "delete".localized().uppercaseFirst,
                    iconName: "delete",
                    tintColor: .appRedColor,
                    handle: { self.deletePost(post) }
                )
            )
        }
        
        if post.author?.userId != Config.currentUser?.id,
            let community = post.community,
            ResponseAPIContentGetProfile.current?.leaderIn?.contains(community.communityId) == true
        {
            actions.append(
                .default(
                    title: "propose to ban".localized().uppercaseFirst,
                    showIcon: false,
                    handle: {
                        self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
                        RestAPIManager.instance.getCommunity(id: community.communityId)
                            .map {$0.issuer}
                            .flatMap {
                                let proposalId = BlockchainManager.instance.generateRandomProposalId()
                                return BlockchainManager.instance.createBanProposal(proposalId: proposalId, communityCode: community.communityId, commnityIssuer: $0 ?? "", permlink: post.contentId.permlink, author: post.author!.userId)
                                    .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                                    .andThen(Single<String>.just(proposalId))
                            }
                            .flatMap {BlockchainManager.instance.approveProposal($0, proposer: ResponseAPIContentGetProfile.current?.userId ?? "")}
                            .subscribe(onSuccess: {_ in
                                self.hideHud()
                                self.showDone("proposal for post banning has been created".localized().uppercaseFirst)
                            }, onError: {error in
                                self.hideHud()
                                self.showError(error)
                            })
                            .disposed(by: self.disposeBag)
                    }
                )
            )
        }

        // headerView for actionSheet
        let headerView = PostMetaView(frame: .zero)
        headerView.setUp(post: post)
        
        let actionSheet = showCMActionSheet(headerView: headerView, actions: actions)
        
        if let community = post.community, !(self is NonAuthVCType)
        {
            ResponseAPIContentGetCommunity.observeItemChanged()
                .filter { $0.identity == community.identity }
                .subscribe(onNext: { newCommunity in
                    // assign new value
                    var actions = actionSheet.actions
                    if let index = actionSheet.actions.firstIndex(where: {$0.id == "follow"}) {
                        actions[index].associatedValue = newCommunity
                    }
                    actionSheet.actions = actions
                    
                    // modify view
                    guard let isSubscribed = newCommunity.isSubscribed, let action = actionSheet.actions.first(where: {$0.id == "follow"}) else { return }
                    
                    let isBeingJoined = newCommunity.isBeingJoined ?? false
                    
                    let info = self.actionInfo(isSubscribed: isSubscribed)
                    action.titleLabel?.text = info.title
                    action.iconImageView?.image = UIImage(named: info.icon)
                    
                    if isBeingJoined {
                        let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 24.0), height: .adaptive(height: 24.0))))
                        activityIndicator.hidesWhenStopped = false
                        activityIndicator.style = .white
                        activityIndicator.color = .appBlackColor
                        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                
                        action.iconImageView?.image = nil
                        action.iconImageView?.addSubview(activityIndicator)
                        activityIndicator.autoPinEdgesToSuperviewEdges()
                        activityIndicator.startAnimating()
                    } else {
                        action.iconImageView?.subviews.first(where: {$0 is UIActivityIndicatorView})?.removeFromSuperview()
                    }
                })
                .disposed(by: actionSheet.disposeBag)
        }
    }
    
    private func handleFollowAction() {
        guard let community = (UIApplication.topViewController() as? CMActionSheet)?.actionWithId("follow")?.associatedValue as? ResponseAPIContentGetCommunity,
            community.isBeingJoined != true
        else {
            return
        }
        BlockchainManager.instance.triggerFollow(community: community)
            .subscribe(onError: { [weak self] (error) in
                self?.showError(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func actionInfo(isSubscribed: Bool) -> (title: String, icon: String) {
        return (title: (isSubscribed ? "following" : "follow").localized().uppercaseFirst, icon: isSubscribed ? "icon-following-black-cyrcle-default" : "icon-follow-black-plus-default")
    }
    
    func load(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let safariVC = SFSafariViewController(url: url, configuration: config)
            safariVC.delegate = self

            present(safariVC, animated: true)
        }
    }
    
    private func deletePost(_ post: ResponseAPIContentGetPost) {
        guard let topController = UIApplication.topViewController()
        else { return }
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this post".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting post".localized().uppercaseFirst)
                    BlockchainManager.instance.deleteMessage(post)
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
    
    private func reportPost(_ post: ResponseAPIContentGetPost) {
        if let nonAuthVC = self as? NonAuthVCType {
            nonAuthVC.showAuthVC()
            return
        }
        
        let vc = ContentReportVC(content: post)
        let nc = SwipeNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    private func editPost(_ post: ResponseAPIContentGetPost) {
        guard let topController = UIApplication.topViewController() else {return}
        
        topController.showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
        
        // Get full post
        RestAPIManager.instance.loadPost(userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.contentId.communityId ?? "")
            .subscribe(onSuccess: {post in
                topController.hideHud()
                if post.document?.attributes?.type == "basic" {
                    let vc = BasicEditorVC(post: post)
                    topController.present(vc, animated: true, completion: nil)
                    return
                }
                
                if post.document?.attributes?.type == "article" {
                    let vc = ArticleEditorVC(post: post)
                    topController.present(vc, animated: true, completion: nil)
                    return
                }
                topController.hideHud()
                topController.showError(CMError.invalidRequest(message: ErrorMessage.unsupportedTypeOfPost.rawValue))
            }, onError: {error in
                topController.hideHud()
                topController.showError(error)
            })
            .disposed(by: disposeBag)
    }
}

extension BaseViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if !isModal {
            dismiss(animated: true, completion: nil)
        }
    }
}
