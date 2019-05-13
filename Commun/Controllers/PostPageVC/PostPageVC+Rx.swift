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

extension PostPageVC: PostHeaderViewDelegate {
    
    func bindUI() {
        viewModel.post
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: {post in
                // Create tableHeaderView
                guard let headerView = UINib(nibName: "PostHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as? PostHeaderView else {return}
                headerView.post = post
                headerView.delegate = self
            
                // Assign table header view
                self.tableView.tableHeaderView = headerView
            })
            .disposed(by: disposeBag)
        
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
                
                if comment.content.embeds.first?.result.type == "video" {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "MediaCommentCell") as! MediaCommentCell
                    cell.setupFromComment(comment)
                    cell.delegate = self
                    return cell
                } else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    cell.setupFromComment(comment)
                    cell.delegate = self
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    
    
}
