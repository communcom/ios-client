//
//  PostCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol PostCellDelegate: class {
    func upvoteButtonDidTouch(post: ResponseAPIContentGetPost)
    func downvoteButtonDidTouch(post: ResponseAPIContentGetPost)
    func menuButtonDidTouch(post: ResponseAPIContentGetPost)
}

extension PostCellDelegate where Self: BaseViewController {
    func upvoteButtonDidTouch(post: ResponseAPIContentGetPost) {
        NetworkService.shared.upvoteMessage(message: post)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func downvoteButtonDidTouch(post: ResponseAPIContentGetPost) {
        NetworkService.shared.downvoteMessage(message: post)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func menuButtonDidTouch(post: ResponseAPIContentGetPost) {
        guard let topController = UIApplication.topViewController() else { return }
        
        var actions = [CommunActionSheet.Action]()
        
        if var community = post.community, let isSubscribed = community.isSubscribed {
            let actionProperties = self.setupAction(isSubscribed: isSubscribed)
            
            let action = CommunActionSheet.Action(title: actionProperties.title, icon: actionProperties.icon, style: .follow, handle: {
                community.isBeingJoined = true
                self.followButtonDidTouch(community: community)
                self.observe(community: community)
            })
            
            actions.append(action)
        }
        
        if post.author?.userId != Config.currentUser?.id {
            actions.append(CommunActionSheet.Action(title: "send report".localized().uppercaseFirst,
                                                    icon: UIImage(named: "report"),
                                                    tintColor: UIColor(hexString: "#ED2C5B")!,
                                                    handle: { self.reportPost(post) }))
        } else {
            actions.append(CommunActionSheet.Action(title: "edit".localized().uppercaseFirst,
                                                    icon: UIImage(named: "edit"),
                                                    handle: { self.editPost(post) }))
        }
        
        actions.append(CommunActionSheet.Action(title: "share".localized().uppercaseFirst,
                                                icon: UIImage(named: "share"),
                                                handle: { ShareHelper.share(post: post) }))

        if post.author?.userId == Config.currentUser?.id {
            actions.append(
                CommunActionSheet.Action(title: "delete".localized().uppercaseFirst,
                                         icon: UIImage(named: "delete"),
                                         tintColor: UIColor(hexString: "#ED2C5B")!,
                                         handle: {
                                            self.deletePost(post)
                })
            )
        }

        // headerView for actionSheet
        let headerView = PostMetaView(frame: .zero)
        headerView.isUserNameTappable = false
        
        topController.showCommunActionSheet(headerView: headerView, actions: actions) {
            headerView.setUp(post: post)
        }
    }
    
    func observe(community: ResponseAPIContentGetCommunity) {
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter { $0.identity == community.identity }
            .subscribe(onNext: { newCommunity in
                guard let isSubscribed = newCommunity.isSubscribed else { return }
                self.updateAction(isSubscribed: isSubscribed)
            })
            .disposed(by: disposeBag)
    }
    
    func setupAction(isSubscribed: Bool) -> (title: String, icon: UIImage) {
        return (title: (isSubscribed ? "following" : "follow").localized().uppercaseFirst, icon: UIImage(named: isSubscribed ? "icon-following-black-cyrcle-default" : "icon-follow-black-plus-default")!)
    }
    
    func updateAction(isSubscribed: Bool) {
        guard let communActionSheet = UIApplication.topViewController() as? CommunActionSheet, var actions = communActionSheet.actions, let actionIndex = communActionSheet.actions?.firstIndex(where: { $0.style == .follow })  else { return }
        
        let actionProperties = setupAction(isSubscribed: isSubscribed)
        communActionSheet.updateAction(byIndex: actionIndex, withProperties: actionProperties)
    }
    
    func deletePost(_ post: ResponseAPIContentGetPost) {
        guard let topController = UIApplication.topViewController()
        else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this post".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting post".localized().uppercaseFirst)
                    NetworkService.shared.deleteMessage(message: post)
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
    
    func reportPost(_ post: ResponseAPIContentGetPost) {
        let vc = ContentReportVC(content: post)
        let nc = BaseNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    func editPost(_ post: ResponseAPIContentGetPost) {
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
                topController.showError(ErrorAPI.invalidData(message: "Unsupported type of post"))
            }, onError: {error in
                topController.hideHud()
                topController.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func followButtonDidTouch(community: ResponseAPIContentGetCommunity) {
        NetworkService.shared.triggerFollow(community: community)
            .subscribe { [weak self] (error) in
                self?.showError(error)
        }
        .disposed(by: disposeBag)
    }
}
