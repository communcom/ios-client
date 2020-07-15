//
//  NonAuthUserProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthUserProfilePageVC: UserProfilePageVC, NonAuthVCType {
    override var authorizationRequired: Bool {false}
    
    override func createHeaderView() -> UserProfileHeaderView {
        let headerView = super.createHeaderView()
        headerView.authorizationRequired = false
        return headerView
    }
    
    override func confirmBlock() {
        showAuthVC()
    }
    
    override func cellSelected(_ indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        switch cell {
        case is PostCell:
            let post = (viewModel as! UserProfilePageViewModel).postsVM.items.value[indexPath.row]
            let postPageVC = NonAuthPostPageVC(post: post)
            self.show(postPageVC, sender: nil)
        case is CommentCell:
            let comment = (viewModel as! UserProfilePageViewModel).commentsVM.items.value[indexPath.row]
            
            guard let userId = comment.parents.post?.userId,
                let permlink = comment.parents.post?.permlink,
                let communityId = comment.parents.post?.communityId
            else {
                return
            }
            
            let postPageVC = NonAuthPostPageVC(userId: userId, permlink: permlink, communityId: communityId)
            postPageVC.selectedComment = comment
    
            self.show(postPageVC, sender: nil)
        default:
            break
        }
    }
}
