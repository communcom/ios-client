//
//  CommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var leftPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPaddingConstraint: NSLayoutConstraint!
    
    private let maxCharactersForReduction = 150
    
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupFromComment(_ comment: ResponseAPIContentGetComment, expanded: Bool = false) {
        self.comment = comment
        
        // if comment is a reply
        if comment.parent.comment != nil {
            leftPaddingConstraint.constant = 72
            rightPaddingConstraint.constant = 16
        } else {
            leftPaddingConstraint.constant = 16
            rightPaddingConstraint.constant = 72
        }
        
        setText(expanded: expanded)
        
        
//        if let html = comment.content.embeds.first?.result.html {
//            let htmlData = NSString(string: html).data(using: String.Encoding.unicode.rawValue)
//            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
//                NSAttributedString.DocumentType.html]
//            let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
//                                                                  options: options,
//                                                                  documentAttributes: nil)
//            contentLabel.attributedText = attributedString
//        } else {
//        }
//        avatarImageView.setAvatar(urlString: comment.author., namePlaceHolder: <#T##String#>)
        #warning("set user's avatar")
        avatarImageView.setNonAvatarImageWithId(comment.author?.username ?? comment.author?.userId ?? "U")
        nameLabel.text = comment.author?.username ?? comment.author?.userId
        timeLabel.text = Date.timeAgo(string: comment.meta.time)
        
        #warning("change this number later")
        voteCountLabel.text = "\(comment.payout.rShares)"
    }
    
    func setText(expanded: Bool = false) {
        guard let content = comment?.content.body.full else {return}
        
        contentLabel.removeGestureRecognizers()
        contentLabel.isUserInteractionEnabled = false
        
        // If text is not so long
        if content.count < maxCharactersForReduction {
            contentLabel.text = content
            return
        }
        
        // If text is long
        if expanded {
            contentLabel.text = content
            return
        }
        
        // If doesn't expanded
        let text = NSMutableAttributedString()
            .normal(String(content.prefix(maxCharactersForReduction - 3)))
            .normal("...")
            .semibold("See More".localized(), color: .appMainColor)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(seeMoreDidTouch(gesture:)))
        contentLabel.isUserInteractionEnabled = true
        contentLabel.addGestureRecognizer(tap)
        
        contentLabel.attributedText = text
    }
    
    @objc func seeMoreDidTouch(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text,
            let comment = comment
            else {return}
        
        let seeMoreRange = (text as NSString).range(of: "See More".localized())
        
        if gesture.didTapAttributedTextInLabel(label: label, inRange: seeMoreRange) {
            delegate?.cell(self, didTapSeeMoreButtonForComment: comment)
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
