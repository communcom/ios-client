//
//  CommentCellDelegate+UIViewController.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension CommentCellDelegate where Self: UIViewController {
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .upvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.voteMessage(voteType: .downvote,
                                          messagePermlink: comment.contentId.permlink,
                                          messageAuthor: comment.author?.username ?? "")
    }
    
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment) {
        showAlert(title: "TODO", message: "Reply comment")
    }
    
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        expandedIndexes.append(indexPath.row)
        UIView.setAnimationsEnabled(false)
        tableView.reloadRows(at: [indexPath], with: .none)
        UIView.setAnimationsEnabled(true)
    }
    
    func cell(_ cell: CommentCell, didTapOnUserName userName: String) {
        if userName != Config.currentUser.id {
            let profile = controllerContainer.resolve(ProfilePageVC.self)!
            profile.viewModel = ProfilePageViewModel()
            profile.viewModel.userId = userName
            show(profile, sender: nil)
            return
        }
        
        // open profile tabbar
        if let profileNC = tabBarController?.viewControllers?.first(where: {$0.tabBarItem.tag == 2}),
            profileNC != tabBarController?.selectedViewController{
            
            UIView.transition(from: tabBarController!.selectedViewController!.view, to: profileNC.view, duration: 0.3, options: UIView.AnimationOptions.transitionFlipFromLeft, completion: nil)
            
            tabBarController?.selectedViewController = profileNC
        }
        
    }
    
    func cell(_ cell: CommentCell, didTapOnTag tag: String) {
        #warning("open tag")
    }
}
