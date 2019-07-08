//
//  PostPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxCocoa
import RxSwift

extension PostPageVC: PostHeaderViewDelegate {
    
    func bindUI() {
        // Observe post
        bindPost()
        
        // Observe comments
        bindComments()
        
        // Observe commentForm
        commentForm.rx.didSubmit
            .subscribe(onNext: {comment in
                self.sendComment(comment)
            })
            .disposed(by: disposeBag)
        
        commentForm.textView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.tableView.scrollToBottom()
            })
            .disposed(by: disposeBag)
    }
    
    func bindPost() {
        // scrollView
        self.tableView.rx.willDragDown
            .map {$0 ? 0: 56}
            .subscribe(onNext: {height in
                UIView.animate(withDuration: 0.25, animations: {
                    self.navigationBarHeightConstraint.constant = CGFloat(height)
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.post
            .subscribe(onNext: {post in
                // Time ago & community
                if let post = post {
                    self.comunityNameLabel.isHidden = false
                    self.timeAgoLabel.isHidden = false
                    self.byUserLabel.isHidden = false
                    self.communityAvatarImageView.isHidden = false
                    
                    self.communityAvatarImageView.setAvatar(urlString: post.community.avatarUrl, namePlaceHolder: post.community.name)
                    self.comunityNameLabel.text = post.community.name
                    self.timeAgoLabel.text = Date.timeAgo(string: post.meta.time)
                    self.byUserLabel.text = "by".localized() + " " + (post.author?.username ?? post.author?.userId ?? "")
                } else {
                    self.comunityNameLabel.isHidden = true
                    self.timeAgoLabel.isHidden = true
                    self.byUserLabel.isHidden = true
                    self.communityAvatarImageView.isHidden = true
                }
                
                
                // Create tableHeaderView
                guard let headerView = UINib(nibName: "PostHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as? PostHeaderView else {return}
                headerView.setUp(with: post)
                headerView.viewDelegate = self
                
                // Assign table header view
                self.tableView.tableHeaderView = headerView
            })
            .disposed(by: disposeBag)
        
        // more button
        let nonNilPost = viewModel.post.filter {$0 != nil}
            .map {$0!}
        
        nonNilPost
            .subscribe(onNext:{post in
                NetworkService.shared.markPostAsRead(permlink: post.contentId.permlink)
            })
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .withLatestFrom(nonNilPost)
            .subscribe(onNext: {_ in
                guard let headerView = self.tableView.tableHeaderView as? PostHeaderView else {return}
                headerView.openMorePostActions()
            })
            .disposed(by: disposeBag)
    }
    
    func bindComments() {
        viewModel.comments
            .map { items -> [ResponseAPIContentGetComment?] in
                if items.count == 0 {
                    return [nil]
                }
                return items
            }
            .bind(to: tableView.rx.items) { table, index, comment in
                guard let comment = comment else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
                    cell.setUpEmptyComment()
                    return cell
                }
                
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                cell.setupFromComment(comment, expanded: self.expandedIndexes.contains(index))
                cell.delegate = self
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.comments
            .subscribe(onNext: {_ in
                self.expandedIndexes = []
            })
            .disposed(by: disposeBag)
    }
    
    func sendComment(_ comment: String) {
        guard self.viewModel.post.value != nil else {return}
        
        viewModel.sendComment(comment, image: commentForm.imageView.image)
            .do(onSubscribed: {
                self.commentForm.sendButton.isEnabled = false
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                self.commentForm.textView.text = ""
                self.view.endEditing(true)
                
                self.commentForm.sendButton.isEnabled = true
                
                #warning("refresh table for testing only")
                self.viewModel.reload()
            }, onError: {error in
                self.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showError(error)
                }
                self.commentForm.sendButton.isEnabled = true
            })
            .disposed(by: disposeBag)
    }
    
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView) {
        self.tableView.tableHeaderView = headerView
    }
}
