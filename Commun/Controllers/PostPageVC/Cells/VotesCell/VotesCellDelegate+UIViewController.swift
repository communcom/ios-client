//
//  VotesCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension VotesCellDelegate where Self: UIViewController {
    func cell(_ voteCell: VotesCell, didTapUpvotePost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Upvote")
    }
    
    func cell(_ voteCell: VotesCell, didTapDownvotePost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Downvote")
    }
    
    func cell(_ voteCell: VotesCell, didTapSharePost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Share")
    }
}
