//
//  CommentForm+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/19/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

extension CommentForm {
    @objc func sendComment() {
        if mode != .new && parentComment == nil { return}
        
        #warning("send image")
        var block: ResponseAPIContentBlock!
        textView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                self.setLoading(true, message: "parsing content".localized().uppercaseFirst)
            })
            .flatMap { parsedBlock -> Single<SendPostCompletion> in
                //clean
                block = parsedBlock
                block.maxId = nil
                
                // send new comment
                let request: Single<SendPostCompletion>
                switch self.mode {
                case .new:
                    request = self.viewModel.sendNewComment(block: block)
                case .edit:
                    request = self.viewModel.updateComment(self.parentComment!, block: block)
                case .reply:
                    request = self.viewModel.replyToComment(self.parentComment!, block: block)
                }
                
                return request
            }
            .do(onSubscribe: {
                self.parentViewController?.showIndetermineHudWithMessage(
                    "sending comment".localized().uppercaseFirst)
            })
            .flatMap { [weak self] (arg) -> Single<ResponseAPIContentGetComment?> in
                let (transactionId, userId, permlink) = arg
                var newComment: ResponseAPIContentGetComment?
                
                switch self?.mode {
                case .edit:
                    newComment = self?.parentComment
                    newComment?.document = block
                case .reply:
                    newComment = ResponseAPIContentGetComment(
                        contentId: ResponseAPIContentId(userId: userId ?? "", permlink: permlink ?? "", communityId: self?.post?.community.communityId ?? ""),
                        parents: ResponseAPIContentGetCommentParent(post: nil, comment: self?.parentComment?.contentId),
                        document: block,
                        author: ResponseAPIAuthor(userId: userId ?? "", username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                        community: self?.post?.community)
                case .new:
                    newComment = ResponseAPIContentGetComment(
                        contentId: ResponseAPIContentId(userId: userId ?? "", permlink: permlink ?? "", communityId: self?.post?.community.communityId ?? ""),
                        parents: ResponseAPIContentGetCommentParent(post: self?.post?.contentId, comment: nil),
                        document: block,
                        author: ResponseAPIAuthor(userId: userId ?? "", username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                        community: self?.post?.community)
                case nil:
                    break
                }
                
                return RestAPIManager.instance.waitForTransactionWith(id: transactionId ?? "")
                    .andThen(Single.just(newComment))
            }
            .subscribe(onSuccess: { [weak self] newComment in
                guard let strongSelf = self, let newComment = newComment else {return}
                strongSelf.setLoading(false)
                switch strongSelf.mode {
                case .edit:
                    newComment.notifyChanged()
                case .reply:
                    strongSelf.parentComment?.children = (strongSelf.parentComment?.children ?? []) + [newComment]
                    strongSelf.parentComment?.notifyChildrenChanged()
                case .new:
                    strongSelf.post?.notifyEvent(
                        eventName: ResponseAPIContentGetPost.commentAddedEventName,
                        object: newComment
                    )
                }
                
                strongSelf.mode = .new
                strongSelf.parentComment = nil
                
            }) { (error) in
                self.setLoading(false)
                self.parentViewController?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func setLoading(_ isLoading: Bool, message: String? = nil) {
        post?.isAddingComment = isLoading
        post?.notifyChanged()
        parentComment?.isReplying = isLoading
        parentComment?.notifyChanged()
        
        textView.isUserInteractionEnabled = !isLoading
        sendButton.isEnabled = !isLoading
        if (isLoading) {
            parentViewController?.showIndetermineHudWithMessage(message ?? "loading".localized().uppercaseFirst)
        }
        else {
            parentViewController?.hideHud()
        }
    }
}
