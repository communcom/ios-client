//
//  PostPageVC+Utilites.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension PostPageVC {
    
    func makeCells() {
        if let post = viewModel.post.value {
            var resultCells: [UITableViewCell] = []
            
            let voteCell = tableView.dequeueReusableCell(withIdentifier: "VotesCell") as! VotesCell
            voteCell.delegate = self
            voteCell.setupFromPost(post)
            resultCells.append(voteCell)
            
            let contentCell = tableView.dequeueReusableCell(withIdentifier: "TextContentCell") as! TextContentCell
            contentCell.setupFromPost(post)
            resultCells.append(contentCell)
            
            cells = resultCells
            tableView.reloadData()
        }
        
    }
    
    func makeComments() {
        var result: [UITableViewCell] = []
        for comment in viewModel.comments.value {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            cell.setupFromComment(comment)
            cell.delegate = self
            result.append(cell)
        }
        
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "WriteCommentCell") as! WriteCommentCell
        result.append(commentCell)
        
        commentCells = result
        tableView.reloadData()
    }
    
}
