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
    @IBOutlet weak var embedView: UIView!
    @IBOutlet weak var embedViewHeightConstraint: NSLayoutConstraint!
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
        
        observeCommentChanged()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupFromComment(_ comment: ResponseAPIContentGetComment, expanded: Bool = false) {
        self.comment = comment
        self.expanded = expanded
        
        // if comment is a reply
        if comment.parent.comment != nil {
            leftPaddingConstraint.constant = 72
            rightPaddingConstraint.constant = 16
        } else {
            leftPaddingConstraint.constant = 16
            rightPaddingConstraint.constant = 72
        }
        
        setText(expanded: expanded)
        
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? comment.author?.userId ?? "U")
        nameLabel.text = comment.author?.username ?? comment.author?.userId
        timeLabel.text = Date.timeAgo(string: comment.meta.time)
        
        // Show media
        let embededResult = comment.content.embeds.first?.result
        
        if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            embedViewHeightConstraint.constant = 142
        } else {
            // TODO: Video
            embedViewHeightConstraint.constant = 0
        }
        
        #warning("change this number later")
        voteCountLabel.text = "\(comment.votes.upCount ?? 0)"
        
        setButton()
    }
    
    func showPhoto(with url: URL) {
        embedView.removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.addTapToViewer()
        
        embedView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: embedView.topAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor, constant: -8).isActive = true
        imageView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            self?.hideLoading()
        }
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
            .semibold("see more".localized(), color: .appMainColor)
        
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
        
        let seeMoreRange = (text as NSString).range(of: "see more".localized())
        
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
    
    @IBAction func replyButtonTap(_ sender: Any) {
        if let comment = comment {
            delegate?.cell(self, didTapReplyButtonForComment: comment)
        }
    }
    
    // MARK: - Observing
    func observeCommentChanged() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommentControllerCommentDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newComment = notification.object as? ResponseAPIContentGetComment,
                    newComment == self.comment
                    else {return}
                self.setupFromComment(newComment, expanded: self.expanded)
            })
            .disposed(by: bag)
    }
    
    // MARK: - Voting
    func setHasVote(_ value: Bool, for type: VoteActionType) {
        guard let comment = comment else {return}
        
        // return if nothing changes
        if type == .upvote && value == comment.votes.hasUpVote {return}
        if type == .downvote && value == comment.votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !self.comment!.votes.hasUpVote
            self.comment!.votes.hasUpVote = voted
            self.comment!.votes.upCount = (self.comment?.votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let voted = !self.comment!.votes.hasDownVote
            self.comment!.votes.hasDownVote = voted
            self.comment!.votes.downCount = (self.comment?.votes.downCount ?? 0) + (voted ? 1: -1)
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
        
        // animation
        animateUpVote()
        
        // notify
        self.comment?.notifyChanged()
        
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
                self.comment?.notifyChanged()
                
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
        
        // animation
        animateDownVote()
        
        // notify
        self.comment?.notifyChanged()
        
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
                    self.comment?.notifyChanged()
                    
                    // re-enable buttons
                    self.upVoteButton.isEnabled = true
                    self.downVoteButton.isEnabled = true
                    
                    // show general error
                    UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: bag)
        
        delegate?.cell(self, didTapDownVoteButtonForComment: comment)
    }
    
    // MARK: - Animations
    func animateUpVote() {
        CATransaction.begin()
        
        let moveUpAnim = CABasicAnimation(keyPath: "position.y")
        moveUpAnim.byValue = -16
        moveUpAnim.autoreverses = true
        self.upVoteButton.layer.add(moveUpAnim, forKey: "moveUp")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.upVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
    
    func animateDownVote() {
        CATransaction.begin()
        
        let moveDownAnim = CABasicAnimation(keyPath: "position.y")
        moveDownAnim.byValue = 16
        moveDownAnim.autoreverses = true
        self.downVoteButton.layer.add(moveDownAnim, forKey: "moveDown")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.downVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
