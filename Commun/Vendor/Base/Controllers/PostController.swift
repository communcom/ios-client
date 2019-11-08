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
    func setUp(with post: ResponseAPIContentGetPost?)
}

extension PostController {
    // MARK: - Notify observers
    func notifyPostChange(newPost: ResponseAPIContentGetPost) {
        newPost.notifyChanged()
    }
    
    func notifyPostDeleted(deletedPost: ResponseAPIContentGetPost) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)Deleted"), object: deletedPost)
    }
    
    func observePostChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newPost = notification.object as? ResponseAPIContentGetPost,
                    newPost.identity == self.post?.identity
                    else {return}
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
            if !FavouritesList.shared.list.contains(post.contentId.permlink) {
                actions.append(
                    CommunActionSheet.Action(title: "add to favourite".localized().uppercaseFirst, icon: UIImage(named: "favourite-add"), handle: {
                        self.addPostToFavourite()
                    })
                )
            }
            else {
                actions.append(
                    CommunActionSheet.Action(title: "remove from favourite".localized().uppercaseFirst, icon: UIImage(named: "favourite-remove"), handle: {
                        self.removeFromFavourite()
                    })
                )
            }
            
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
        guard let topController = UIApplication.topViewController(), let post = post else { return }

        var urlString = "https:/dev.commun.com/"
        #warning("add post url api value")
        if let alias = post.community.alias, let username = post.author?.username  {
            urlString = "https:/dev.commun.com/\(alias)/@\(username)/\(post.contentId.permlink)"
        }
        let url = URL(string: urlString)
        let activity = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        topController.present(activity, animated: true)
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
        
        // animate
        animateUpVote {
            // notify
            self.notifyPostChange(newPost: self.post!)
            
            // disable button until transaction is done
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            
            // send request
            NetworkService.shared.voteMessage(voteType:          originHasUpVote ? .unvote: .upvote,
                                              messagePermlink:   post.contentId.permlink,
                                              messageAuthor:     post.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable buttons
                        self?.upVoteButton.isEnabled = true
                        self?.downVoteButton.isEnabled = true
                    },
                    onError: {[weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.notifyPostChange(newPost: strongSelf.post!)
                        
                        // re-enable buttons
                        strongSelf.upVoteButton.isEnabled = true
                        strongSelf.downVoteButton.isEnabled = true
                        
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
        
        // animate
        animateDownVote {
            // notify
            self.notifyPostChange(newPost: self.post!)
            
            // disable button until transaction is done
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            
            // send request
            NetworkService.shared.voteMessage(voteType:          originHasDownVote ? .unvote: .downvote,
                                              messagePermlink:   post.contentId.permlink,
                                              messageAuthor:     post.author?.userId ?? "")
                .subscribe(
                    onCompleted: { [weak self] in
                        // re-enable buttons
                        self?.upVoteButton.isEnabled = true
                        self?.downVoteButton.isEnabled = true
                    },
                    onError: { [weak self] error in
                        guard let strongSelf = self else {return}
                        // reset state
                        strongSelf.setHasVote(originHasUpVote, for: .upvote)
                        strongSelf.setHasVote(originHasDownVote, for: .downvote)
                        strongSelf.notifyPostChange(newPost: strongSelf.post!)
                        
                        // re-enable buttons
                        strongSelf.upVoteButton.isEnabled = true
                        strongSelf.downVoteButton.isEnabled = true
                        
                        // show general error
                        UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: - Other actions
    func sharePost() {
        guard let post = post,
            let userId = post.author?.userId,
            let controller = UIApplication.topViewController()
            else {return}
        // text to share
        let title = post.document?.attributes?.title
        var text = (title != nil) ? (title! + "\n"): ""
        
        text += "\(URL.appURL)/posts/\(userId)/\(post.contentId.permlink)"
        
        
        // link to share
        let textToShare = [text]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        
        // present the view controller
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
    func reportPost() {
        #warning("Report post")
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
                    NetworkService.shared.deletePost(permlink: post.contentId.permlink)
                    .subscribe(onCompleted: {
                        self.notifyPostDeleted(deletedPost: post)
                    }, onError: { error in
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
        NetworkService.shared.getPost(withPermLink: post.contentId.permlink)
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
        notifyPostChange(newPost: self.post!)
    }

    // MARK: - Animation
    func animateUpVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let moveUpAnim = CABasicAnimation(keyPath: "position.y")
        moveUpAnim.byValue = -16
        moveUpAnim.autoreverses = true
        self.upVoteButton.layer.add(moveUpAnim, forKey: "moveUp")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.upVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
    
    func animateDownVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let moveDownAnim = CABasicAnimation(keyPath: "position.y")
        moveDownAnim.byValue = 16
        moveDownAnim.autoreverses = true
        self.downVoteButton.layer.add(moveDownAnim, forKey: "moveDown")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.downVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
