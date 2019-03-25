//
//  PostPageVC+VotesCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension PostPageVC: VotesCellDelegate {
    
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
