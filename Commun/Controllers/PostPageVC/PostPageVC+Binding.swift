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
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let deletedPost = notification.object as? ResponseAPIContentGetPost,
                    deletedPost.identity == (self.viewModel as! PostPageViewModel).post.value?.identity
                    else {return}
                self.showAlert(title: "deleted".localized().uppercaseFirst, message: "the post has been deleted".localized().uppercaseFirst, completion: { (_) in
                    self.back()
                })
            })
            .disposed(by: disposeBag)
    }
    
    func bindControls() {
        tableView.rx.willDragDown
            .map {$0 ? 0: 56}
            .distinctUntilChanged()
            .subscribe(onNext: {height in
                UIView.animate(withDuration: 0.25, animations: {
                    self.navigationBar.heightConstraint?.constant = CGFloat(height)
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
    
    func bindPost() {
        let viewModel = self.viewModel as! PostPageViewModel
            
        // bind post loading state
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    break
//                    self?._headerView.showLoader()
                case .finished:
                    break
//                    self?._headerView.hideLoader()
                case .error(_):
                    guard let strongSelf = self else {return}
//                    strongSelf._headerView.hideLoader()
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
//                if self.headerView == nil {
//                    self.createHeaderView()
//                }
//                self.headerView.setUp(with: post)
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
