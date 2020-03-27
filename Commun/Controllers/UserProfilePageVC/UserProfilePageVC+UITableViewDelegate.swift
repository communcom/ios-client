//
//  UserProfilePageVC+UITableViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 3/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UserProfilePageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return (viewModel as! UserProfilePageViewModel).postsVM.rowHeights[post.identity] ?? UITableView.automaticDimension
        case let comment as ResponseAPIContentGetComment:
            return (viewModel as! UserProfilePageViewModel).commentsVM.rowHeights[comment.identity] ?? UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return (viewModel as! UserProfilePageViewModel).postsVM.rowHeights[post.identity] ?? 200
        case let comment as ResponseAPIContentGetComment:
            return (viewModel as! UserProfilePageViewModel).commentsVM.rowHeights[comment.identity] ?? 88
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            (viewModel as! UserProfilePageViewModel).postsVM.rowHeights[post.identity] = cell.bounds.height
            
            // record post view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if tableView.isCellVisible(indexPath: indexPath) &&
                    (cell as! PostCell).post?.identity == post.identity &&
                    !RestAPIManager.instance.markedAsViewedPosts.contains(post.identity)
                {
                    post.markAsViewed().disposed(by: self.disposeBag)
                }
            }
        case let comment as ResponseAPIContentGetComment:
            (viewModel as! UserProfilePageViewModel).commentsVM.rowHeights[comment.identity] = cell.bounds.height
        default:
            break
        }
    }
}
