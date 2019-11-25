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
    var voteContainerView: VoteContainerView {get set}
    var post: ResponseAPIContentGetPost? {get set}
    func setUp(with post: ResponseAPIContentGetPost?)
}

extension PostController {
    func observePostChange() {
        ResponseAPIContentGetPost.observeItemChanged()
            .subscribe(onNext: {newPost in
                self.setUp(with: newPost)
            })
            .disposed(by: disposeBag)
    }
    
    func openMorePostActions() {
        guard let topController = UIApplication.topViewController(),
            let post = post
        else {return}
        
        var actions = [CommunActionSheet.Action]()
        
        if post.author?.userId != Config.currentUser?.id {
            // remove from MVP
//            if !FavouritesList.shared.list.contains(post.contentId.permlink) {
//                actions.append(
//                    CommunActionSheet.Action(title: "add to favourite".localized().uppercaseFirst, icon: UIImage(named: "favourite-add"), handle: {
//                        self.addPostToFavourite()
//                    })
//                )
//            }
//            else {
//                actions.append(
//                    CommunActionSheet.Action(title: "remove from favourite".localized().uppercaseFirst, icon: UIImage(named: "favourite-remove"), handle: {
//                        self.removeFromFavourite()
//                    })
//                )
//            }
            
            actions.append(
                CommunActionSheet.Action(title: "send report".localized().uppercaseFirst, icon: UIImage(named: "report"), handle: {
                    self.reportPost()
                }, tintColor: UIColor(hexString: "#ED2C5B")!)
            )
        }
        else {
            actions += [
                CommunActionSheet.Action(title: "edit".localized().uppercaseFirst, icon: UIImage(named: "edit"), handle: {
                    self.editPost()
                }),
                CommunActionSheet.Action(title: "delete".localized().uppercaseFirst, icon: UIImage(named: "delete"), handle: {
                    self.deletePost()
                }, tintColor: UIColor(hexString: "#ED2C5B")!)
            ]
        }
        
        actions.append(
            CommunActionSheet.Action(title: "share".localized().uppercaseFirst, icon: UIImage(named: "share"), handle: {
                self.sharePost()
            })
        )
        
        // headerView for actionSheet
        let headerView = PostMetaView(frame: .zero)
        headerView.isUserNameTappable = false
        
        topController.showCommunActionSheet(headerView: headerView, actions: actions) {
            headerView.setUp(post: post)
        }
    }

    func openShareActions() {
        ShareHelper.share(post: post)
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let post = post else {return}
        
        // return if nothing changes
        if type == .upvote && value == post.votes.hasUpVote {return}
        if type == .downvote && value == post.votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !(self.post!.votes.hasUpVote ?? false)
            self.post!.votes.hasUpVote = voted
            self.post!.votes.upCount = (self.post?.votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let downVoted = !(self.post!.votes.hasDownVote ?? false)
            self.post!.votes.hasDownVote = downVoted
            self.post!.votes.downCount = (self.post?.votes.downCount ?? 0) + (downVoted ? 1: -1)
        }
    }
    
    func upVote() {
        guard let post = post else {return}
        
        // save original state
        let originHasUpVote = post.votes.hasUpVote ?? false
        let originHasDownVote = post.votes.hasDownVote ?? false
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        self.post!.votes.isBeingVoted = true
        
        // animate
        voteContainerView.animateUpVote {
            // notify
            self.post!.notifyChanged()
            
            // send request
            NetworkService.shared.voteMessage(voteType: originHasUpVote ? .unvote: .upvote,
                                              communityId: post.community.communityId,
                                              messagePermlink: post.contentId.permlink,
                                              messageAuthor: post.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable state
                        self?.post?.votes.isBeingVoted = false
                        self?.post?.notifyChanged()
                    },
                    onError: {[weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.post?.votes.isBeingVoted = false
                        strongSelf.post!.notifyChanged()
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
        
        
        
        
    }
    
    func downVote() {
        guard let post = post else {return}
        
        // save original state
        let originHasUpVote = post.votes.hasUpVote ?? false
        let originHasDownVote = post.votes.hasDownVote ?? false
        
        // change state
        setHasVote(originHasDownVote ? false: true, for: .downvote)
        setHasVote(false, for: .upvote)
        self.post!.votes.isBeingVoted = true
        
        // animate
        voteContainerView.animateDownVote {
            // notify
            self.post!.notifyChanged()
            
            // send request
            NetworkService.shared.voteMessage(voteType: originHasDownVote ? .unvote: .downvote,
                                              communityId: post.community.communityId,
                                              messagePermlink: post.contentId.permlink,
                                              messageAuthor: post.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable state
                        self?.post?.votes.isBeingVoted = false
                        self?.post?.notifyChanged()
                    },
                    onError: { [weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.post?.votes.isBeingVoted = false
                        strongSelf.post!.notifyChanged()
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: - Other actions
    func sharePost() {
        ShareHelper.share(post: post)
    }
    
    func reportPost() {
        guard let post = post else {return}
        let vc = PostReportVC(post: post)
        let nc = BaseNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    func deletePost() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this post".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1)
            { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting post".localized().uppercaseFirst)
                    NetworkService.shared.deletePost(
                        communCode: post.community.communityId,
                        permlink: post.contentId.permlink
                    )
                    .subscribe(onCompleted: {
                        topController.hideHud()
                        post.notifyDeleted()
                    }, onError: { error in
                        topController.hideHud()
                        topController.showError(error)
                    })
                    .disposed(by: self.disposeBag)
                }
            }
    }
    
    func editPost() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        topController.showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
        // Get full post
        RestAPIManager.instance.loadPost(userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.contentId.communityId ?? "")
            .subscribe(onSuccess: {post in
                topController.hideHud()
                if post.document?.attributes?.type == "basic" {
                    let vc = BasicEditorVC()
                    vc.viewModel.postForEdit = post
                    vc.modalPresentationStyle = .fullScreen
                    topController.present(vc, animated: true, completion: nil)
                    return
                }
                
                if post.document?.attributes?.type == "article" {
                    let vc = ArticleEditorVC()
                    vc.viewModel.postForEdit = post
                    vc.modalPresentationStyle = .fullScreen
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
    
    func addPostToFavourite() {
        let favourites = FavouritesList.shared.list
        guard let post = post,
            !favourites.contains(post.contentId.permlink),
            let topController = UIApplication.topViewController()
        else {
            return
        }
        
        FavouritesList.shared.add(permlink: post.contentId.permlink)
            .subscribe(onCompleted: {
                topController.showDone("added to favourite".localized().uppercaseFirst)
            })
            .disposed(by: disposeBag)
    }
    
    func removeFromFavourite() {
        let favourites = FavouritesList.shared.list
        guard let post = post,
            favourites.contains(post.contentId.permlink),
            let topController = UIApplication.topViewController()
        else {
            return
        }
        
        FavouritesList.shared.remove(permlink: post.contentId.permlink)
            .subscribe(onCompleted: {
                topController.showDone("removed from favourite".localized().uppercaseFirst)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Commented
    func postDidComment() {
        guard post != nil else {return}
        self.post!.stats?.commentsCount += 1
        self.post!.notifyChanged()
    }
}
