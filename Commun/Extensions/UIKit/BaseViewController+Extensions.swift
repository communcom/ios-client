//
//  BaseViewController+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 6/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

extension BaseViewController {
    func showPostMenu(post: ResponseAPIContentGetPost) {
        var actions = [CMActionSheet.Action]()
        actions.append(
            .default(
                title: "view in Explorer".localized().uppercaseFirst,
                showIcon: false,
                handle: {
                    self.load(url: "https://explorer.cyberway.io/trx/\(post.meta.trxId ?? "")")
                }
            )
        )
        
        if let community = post.community, let isSubscribed = community.isSubscribed,
            !(self is NonAuthVCType)
        {
            let actionProperties = self.actionInfo(isSubscribed: isSubscribed)
            
            var action = CMActionSheet.Action.default(
                title: actionProperties.title,
                iconName: actionProperties.icon,
                handle: {
                    self.followButtonDidTouch()
                    self.observeCommunity()
                }
            )
            
            action.id = "follow"
            action.dismissActionSheetOnCompleted = false
            
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

        // headerView for actionSheet
        let headerView = PostMetaView(frame: .zero)
        headerView.setUp(post: post)
        
        showCMActionSheet(headerView: headerView, actions: actions)
    }
    
    private func actionInfo(isSubscribed: Bool) -> (title: String, icon: String) {
        return (title: (isSubscribed ? "following" : "follow").localized().uppercaseFirst, icon: isSubscribed ? "icon-following-black-cyrcle-default" : "icon-follow-black-plus-default")
    }
    
    func followButtonDidTouch() {
        guard   let communActionSheet = UIApplication.topViewController() as? CommunActionSheet,
                let index = communActionSheet.actions?.firstIndex(where: { $0.style == .follow }),
                let community = communActionSheet.actions?[index].post?.community else { return }
       
        communActionSheet.loaderDidStart(withTitle: (community.isSubscribed ?? false ? "follow" : "following").localized().uppercaseFirst)
        
        BlockchainManager.instance.triggerFollow(community: community)
            .subscribe { [weak self] (error) in
                self?.showError(error)
        }
        .disposed(by: disposeBag)
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
    
    private func observeCommunity() {
        guard   let communActionSheet = UIApplication.topViewController() as? CommunActionSheet,
                let index = communActionSheet.actions?.firstIndex(where: { $0.style == .follow }),
                let post = communActionSheet.actions?[index].post else { return }

        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter { $0.identity == post.community?.identity }
            .subscribe(onNext: { newCommunity in
                guard let isSubscribed = newCommunity.isSubscribed, let community = post.community, isSubscribed != community.isSubscribed else { return }
                communActionSheet.updateFollowAction(withCommunity: newCommunity)
                
                var postTemp = post
                postTemp.community = newCommunity
                
                self.update(post: postTemp)
                NotificationCenter.default.removeObserver(self)
            })
            .disposed(by: disposeBag)
    }
        
    private func update(post: ResponseAPIContentGetPost) {
        guard let postsVC = self as? PostsViewController else { return }
        postsVC.viewModel.updateItem(post)
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
