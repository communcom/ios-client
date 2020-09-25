//
//  UserProfilePageVC+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 3/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UserProfilePageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return (viewModel as! UserProfilePageViewModel).postsVM.rowHeights[post.identity] ?? 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case var post as ResponseAPIContentGetPost:
            (viewModel as! UserProfilePageViewModel).postsVM.rowHeights[post.identity] = cell.bounds.height
            
            // record post view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if tableView.isCellVisible(indexPath: indexPath) &&
                    (cell as? PostCell)?.postIdentity == post.identity &&
                    !RestAPIManager.instance.markedAsViewedPosts.contains(post.identity)
                {
                    post.markAsViewed().disposed(by: self.disposeBag)
                }
            }
            
            // hide donation buttons when cell was removed
            if !tableView.isCellVisible(indexPath: indexPath), post.showDonationButtons == true {
                post.showDonationButtons = false
                post.notifyChanged()
            }
        case let comment as ResponseAPIContentGetComment:
            guard let cell = cell as? CommentCell, cell.comment?.identity == comment.identity else {return}
            (viewModel as! UserProfilePageViewModel).commentsVM.rowHeights[comment.identity] = cell.bounds.height
        default:
            break
        }
    }
}
