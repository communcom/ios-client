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
    }
    
    func bindPost() {
        viewModel.post
            .subscribe(onNext: {post in
                // Community avatar
                self.communityAvatarImageView.setAvatar(urlString: post?.community.avatarUrl, namePlaceHolder: post?.community.name ?? "C")
                
                // Time ago & community
                self.comunityNameLabel.text = post?.community.name
                if let timeString = post?.meta.time {
                    self.timeAgoLabel.text = Date.timeAgo(string: timeString)
                }
                self.byUserLabel.text = "by".localized() + " " + (post?.author?.username ?? post?.author?.userId ?? "")
                
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
                
                if index >= self.viewModel.comments.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                cell.setupFromComment(comment)
                cell.delegate = self
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    func sendComment(_ comment: String) {
        guard let post = self.viewModel.post.value else {return}
        NetworkService.shared.sendComment(comment: comment, forPostWithPermlink: post.contentId.permlink, tags: [])
            .do(onSubscribe: {
                self.commentForm.sendButton.isEnabled = false
            })
            .subscribe(onCompleted: {
                self.commentForm.textView.text = ""
                self.view.endEditing(true)
                
                self.commentForm.sendButton.isEnabled = true
                
                #warning("refresh table for testing only")
                self.viewModel.reload()
            }, onError: {_ in
                self.view.endEditing(true)
                self.showGeneralError()
                self.commentForm.sendButton.isEnabled = true
            })
            .disposed(by: disposeBag)
    }
    
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView) {
        self.tableView.tableHeaderView = headerView
    }
}
