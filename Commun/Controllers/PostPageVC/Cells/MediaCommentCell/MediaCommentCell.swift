//
//  MediaCommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import WebKit

class MediaCommentCell: UITableViewCell, CommentCellProtocol {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
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
            webView.loadHTMLString(html, baseURL: nil)
        }
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
