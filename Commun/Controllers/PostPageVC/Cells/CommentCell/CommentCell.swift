//
//  CommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func cell(_ cell: CommentCellProtocol, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCellProtocol, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCellProtocol, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
}

protocol CommentCellProtocol {
    func upVoteButtonTap(_ sender: Any)
    
    func downVoteButtonTap(_ sender: Any)
    
    func replyButtonTap(_ sender: Any)
}

class CommentCell: UITableViewCell, CommentCellProtocol {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupFromComment(_ comment: ResponseAPIContentGetComment) {
        self.comment = comment
        
        if let html = comment.content.embeds.first?.result.html {
            let htmlData = NSString(string: html).data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                NSAttributedString.DocumentType.html]
            let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                                  options: options,
                                                                  documentAttributes: nil)
            contentLabel.attributedText = attributedString
        } else {
            contentLabel.text = comment.content.body.full
        }
        
        nameLabel.text = comment.author?.username ?? ""
        voteCountLabel.text = "\(comment.payout.rShares)"
    }
    
    @IBAction func upVoteButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapUpVoteButtonForComment: comment)
        }
    }
    
    @IBAction func downVoteButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapDownVoteButtonForComment: comment)
        }
    }
    
    @IBAction func replyButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapReplyButtonForComment: comment)
        }
    }
    
}
