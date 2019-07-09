//
//  CommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import RxSwift

protocol CommentCellDelegate: class {
    var expandedIndexes: [Int] {get set}
    var tableView: UITableView! {get set}
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnUserName userName: String)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var leftPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPaddingConstraint: NSLayoutConstraint!
    
    private let maxCharactersForReduction = 150
    
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    let bag = DisposeBag()
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(contentLabelDidTouch(gesture:)))
        contentLabel.addGestureRecognizer(tap)
        
        let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(authorDidTouch(gesture:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapOnAvatar)
        
        let tapOnUserName = UITapGestureRecognizer(target: self, action: #selector(authorDidTouch(gesture:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tapOnUserName)
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
        
        #warning("set user's avatar")
        avatarImageView.setNonAvatarImageWithId(comment.author?.username ?? comment.author?.userId ?? "U")
        nameLabel.text = comment.author?.username ?? comment.author?.userId
        timeLabel.text = Date.timeAgo(string: comment.meta.time)
        
        #warning("change this number later")
        voteCountLabel.text = "\(comment.payout.rShares)"
        
        setButton()
    }
    
    func setButton() {
        // Handle button
        upVoteButton.setImage(UIImage(named: comment?.votes.hasUpVote == true ? "icon-up-selected" : "icon-up-default"), for: .normal)
        downVoteButton.setImage(UIImage(named: comment?.votes.hasDownVote == true ? "icon-down-selected" : "icon-down-default"), for: .normal)
    }
    
    func setText(expanded: Bool = false) {
        guard let content = comment?.content.body.full else {return}
        
        // If text is not so long
        if content.count < maxCharactersForReduction {
            contentLabel.text = content
            contentLabel.highlightTagsAndUserNames()
            return
        }
        
        // If text is long
        if expanded {
            contentLabel.text = content
            contentLabel.highlightTagsAndUserNames()
            return
        }
        
        // If doesn't expanded
        let text = NSMutableAttributedString()
            .normal(String(content.prefix(maxCharactersForReduction - 3)))
            .normal("...")
            .semibold("See More".localized(), color: .appMainColor)
        
        contentLabel.text = text
    }
    
    @objc func authorDidTouch(gesture: UITapGestureRecognizer) {
        guard let userId = comment?.author?.userId else {return}
        delegate?.cell(self, didTapOnUserName: userId)
    }
    
    @objc func contentLabelDidTouch(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text,
            let comment = comment
            else {return}
        
        let seeMoreRange = (text as NSString).range(of: "See More".localized())
        
        if gesture.didTapAttributedTextInLabel(label: label, inRange: seeMoreRange) {
            delegate?.cell(self, didTapSeeMoreButtonForComment: comment)
            return
        }
        
        for userName in text.getMentions() {
            let range = (text as NSString).range(of: "@\(userName)")
            if gesture.didTapAttributedTextInLabel(label: label, inRange: range) {
                delegate?.cell(self, didTapOnUserName: userName)
                return
            }
        }
        
        for tag in text.getTags() {
            let range = (text as NSString).range(of: "#\(tag)")
            if gesture.didTapAttributedTextInLabel(label: label, inRange: range) {
                delegate?.cell(self, didTapOnTag: tag)
                return
            }
        }
    }
    
    @IBAction func upVoteButtonTap(_ sender: Any) {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote
        let originHasDownVote = comment.votes.hasDownVote
        
        // change state
        setHasVote(originHasUpVote ? false: true, for: .upvote)
        setHasVote(false, for: .downvote)
        
        // disable button ntil transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType: originHasUpVote ? .unvote: .upvote, messagePermlink: comment.contentId.permlink, messageAuthor: comment.author?.userId ?? "")
            .subscribe(onCompleted: {
                // re-enable buttons
                self.upVoteButton.isEnabled = true
                self.downVoteButton.isEnabled = true
            }) { (error) in
                // reset state
                self.setHasVote(originHasUpVote, for: .upvote)
                self.setHasVote(originHasDownVote, for: .downvote)
                
                // re-enable buttons
                self.upVoteButton.isEnabled = true
                self.downVoteButton.isEnabled = true
                
                // show general error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: bag)
        
        delegate?.cell(self, didTapUpVoteButtonForComment: comment)
    }
    
    @IBAction func downVoteButtonTap(_ sender: Any) {
        guard let comment = comment else {return}
        
        // save original state
        let originHasUpVote = comment.votes.hasUpVote
        let originHasDownVote = comment.votes.hasDownVote
        
        // change state
        setHasVote(originHasDownVote ? false: true, for: .downvote)
        setHasVote(false, for: .upvote)
        
        // disable button until transaction is done
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        
        // send request
        NetworkService.shared.voteMessage(voteType:          originHasDownVote ? .unvote: .downvote,
                                          messagePermlink:   comment.contentId.permlink,
                                          messageAuthor:     comment.author?.userId ?? "")
            .subscribe(
                onCompleted: {
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
            },
                onError: { error in
                    // reset state
                    self.setHasVote(originHasUpVote, for: .upvote)
                    self.setHasVote(originHasDownVote, for: .downvote)
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: bag)
        
        delegate?.cell(self, didTapDownVoteButtonForComment: comment)
    }
    
    @IBAction func replyButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapReplyButtonForComment: comment)
        }
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let comment = comment else {return}
        
        // return if nothing changes
        if type == .upvote && value == comment.votes.hasUpVote {return}
        if type == .downvote && value == comment.votes.hasDownVote {return}
        
        if type == .upvote {
            self.comment!.votes.hasUpVote = !self.comment!.votes.hasUpVote
        }
        
        if type == .downvote {
            self.comment!.votes.hasDownVote = !self.comment!.votes.hasDownVote
        }
        
        setButton()
    }
    
}
