//
//  PostPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC {
    func observePostDeleted() {
        ResponseAPIContentGetPost.observeItemDeleted()
            .subscribe(onNext: { (deletedPost) in
                guard deletedPost.identity == (self.viewModel as! PostPageViewModel).post.value?.identity
                    else {return}
                self.showAlert(title: "deleted".localized().uppercaseFirst, message: "the post has been deleted".localized().uppercaseFirst, completion: { (_) in
                    self.back()
                })
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: {blockedUser in
                let post = (self.viewModel as! PostPageViewModel).post.value
                if post?.author?.userId == blockedUser.userId {
                    self.back()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommunityBlocked() {
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedCommunity) in
                let post = (self.viewModel as! PostPageViewModel).post.value
                if post?.community.communityId == blockedCommunity.communityId {
                    self.back()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommentAdded() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)\(ResponseAPIContentGetPost.commentAddedEventName)"))
            .subscribe(onNext: { (notification) in
                guard let newComment = notification.object as? ResponseAPIContentGetComment else {return}
                
                // add newComment to top of the list
                var items = self.viewModel.items.value
                items = items + [newComment]
                self.viewModel.items.accept(items)
                self.handleListEnded()
            })
            .disposed(by: disposeBag)
    }
    
    func bindControls() {
//        tableView.rx.willDragDown
//            .map {$0 ? true: false}
//            .distinctUntilChanged()
//            .subscribe(onNext: {hide in
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.navigationBar.isHidden = hide
//                    self.view.layoutIfNeeded()
//                })
//            })
//            .disposed(by: disposeBag)
    }
    
    func bindPost() {
        let viewModel = self.viewModel as! PostPageViewModel
            
        // bind post loading state
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?.postView.showLoader()
                case .finished:
                    self?.postView.hideLoader()
                case .error(_):
                    self?.postView.hideLoader()
                    guard let strongSelf = self else {return}
                    strongSelf.view.showErrorView {
                        strongSelf.view.hideErrorView()
                        strongSelf.refresh()
                    }
                    strongSelf.view.bringSubviewToFront(strongSelf.navigationBar)
                }
            })
            .disposed(by: disposeBag)
        // bind post
        let post = viewModel.post
        post
            .subscribe(onNext: {post in
                if let post = post {
                    self.navigationBar.setUp(with: post)
                    
                    // commentForm
    //                if self.replyingComment == nil {
    //                    self.commentForm.parentAuthor = post.contentId.userId
    //                    self.commentForm.parentPermlink = post.contentId.permlink
    //                }
                }
                
                // Create tableHeaderView
                self.postView.setUp(with: post)
            })
            .disposed(by: disposeBag)
        
        // Mark post as read
        post.filter{$0 != nil}.map {$0!}
            .take(1).asSingle()
            .flatMap {NetworkService.shared.markPostAsRead(permlink: $0.contentId.permlink)}
            .subscribe(onSuccess: {_ in
                Logger.log(message: "Marked post as read", event: .severe)
            })
            .disposed(by: disposeBag)
    }
}
