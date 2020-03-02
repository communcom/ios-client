//
//  PostPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
                if post?.community?.communityId == blockedCommunity.communityId {
                    self.back()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommentAdded() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)\(ResponseAPIContentGetPost.commentAddedEventName)"))
            .subscribe(onNext: { (notification) in
                guard let newComment = notification.object as? ResponseAPIContentGetComment else {return}
                
                // add newComment to bottom of the list
                var items = self.viewModel.items.value
                items += [newComment]
                self.viewModel.items.accept(items)
                self.handleListEnded()
                
                DispatchQueue.main.async {
                    self.tableView.safeScrollToRow(at: IndexPath(row: 0, section: self.tableView.numberOfSections - 1), at: .bottom, animated: true)
                }
                
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
        
        // Shadow on navigation bar
        tableView.rx.contentOffset
            .map { $0.y <= self.startContentOffsetY }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { (showShadow) in
                self.navigationBar.addShadow(ofColor: showShadow ? .clear : .shadow, radius: 20, offset: CGSize(width: 0, height: 3), opacity: 0.07)
            })
            .disposed(by: disposeBag)
        
        commentForm.textView.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                
                 // textView
                 let contentSize = self.commentForm.textView.sizeThatFits(CGSize(width: self.commentForm.textView.width, height: .greatestFiniteMagnitude))
                 
                 if self.shadowView.frame.minY > self.commentFormMinPaddingTop || contentSize.height < self.commentForm.textView.height
                 {
                     if self.commentForm.textView.isScrollEnabled {
                        // TODO: - Temporary solution for fixing textView layout
                        self.commentForm.textView.text = text + " "
                        DispatchQueue.main.async {
                            self.commentForm.textView.text = text
                        }
                     }
                     self.commentForm.textView.isScrollEnabled = false
                     
                 } else {
                     if !self.commentForm.textView.isScrollEnabled {
//                         self.commentForm.textView.setNeedsLayout()
                     }
                     self.commentForm.textView.isScrollEnabled = true
                 }
            })
            .disposed(by: disposeBag)
        
        // forward delegate
        commentForm.textView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bindPost() {
        let viewModel = self.viewModel as! PostPageViewModel
            
        // bind post loading state
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?.postHeaderView.showLoader()
                case .finished:
                    self?.postHeaderView.hideLoader()
                case .error:
                    self?.postHeaderView.hideLoader()
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
            .subscribe(onNext: { post in
                guard let post = post else {return}
                self.navigationBar.setUp(with: post)
                self.commentForm.post = post
                self.postHeaderView.setUp(with: post)
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    self.scrollToTopAfterLoadingComment = true
//                }
            })
            .disposed(by: disposeBag)
        
        // Mark post as read
        post.filter {$0 != nil}.map {$0!}
            .take(1).asSingle()
            .flatMap {NetworkService.shared.markPostAsRead(permlink: $0.contentId.permlink)}
            .subscribe(onSuccess: {_ in
                Logger.log(message: "Marked post as read", event: .severe)
            })
            .disposed(by: disposeBag)
    }
}
