//
//  VotesCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol VotesCellDelegate {
    func cell(_ voteCell: VotesCell, didTapUpvotePost post: ResponseAPIContentGetPost)
    func cell(_ voteCell: VotesCell, didTapDownvotePost post: ResponseAPIContentGetPost)
    func cell(_ voteCell: VotesCell, didTapSharePost post: ResponseAPIContentGetPost)
}

class VotesCell: UITableViewCell {

    @IBOutlet weak var votesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    var post: ResponseAPIContentGetPost?
    var delegate: VotesCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupFromPost(_ post: ResponseAPIContentGetPost) {
        self.post = post
    }
    
    @IBAction func upvoteButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.cell(self, didTapUpvotePost: post)
        }
    }
    
    @IBAction func downvoteButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.cell(self, didTapDownvotePost: post)
        }
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.cell(self, didTapSharePost: post)
        }
    }
    
}
