//
//  PostCardCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import SDWebImage
import RxSwift


class PostCardCell: UITableViewCell, PostController {
    var disposeBag = DisposeBag()
    

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var likeCounterLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfSharesLabel: UILabel!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    @IBOutlet weak var embededImageView: UIImageView!
    @IBOutlet weak var embededViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var embededImageViewToContainerBottomConstraint: NSLayoutConstraint!
    var post: ResponseAPIContentGetPost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        avatarImageView.layer.cornerRadius = avatarImageView.height / 2
        avatarImageView.clipsToBounds = true
        
        // add gesture to authorNameLabel
        let tap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped(_:)))
        authorNameLabel.isUserInteractionEnabled = true
        authorNameLabel.addGestureRecognizer(tap)
        
        // Observe change
        observePostChange()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func menuButtonTap(_ sender: Any) {
        openMorePostActions()
    }
    
    @IBAction func upButtonTap(_ sender: Any) {
        upVote()
    }
    
    @IBAction func downButtonTap(_ sender: Any) {
        downVote()
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        sharePost()
    }
    
    @objc func userNameTapped(_ sender: UITapGestureRecognizer) {
        guard let userId = post?.author?.userId else {return}
        parentViewController?.showProfileWithUserId(userId)
    }
}

extension PostCardCell {
    
    func setUp(with post: ResponseAPIContentGetPost?) {
        guard let post = post else {return}
        self.post = post
        self.avatarImageView.setAvatar(urlString: post.community.avatarUrl, namePlaceHolder: post.community.name)
        
        self.titleLabel.text = post.community.name.lowercased().uppercaseFirst
        self.timeAgoLabel.text = Date.timeAgo(string: post.meta.time)
        
        self.authorNameLabel.text = "by".localized() + " " + (post.author?.username ?? post.author?.userId ?? "")
        
        self.mainTextLabel.text = post.content.title
        self.accessibilityLabel = "PostCardCell"
        
        if let imageURL = post.firstEmbedImageURL {
            embededImageView.sd_setImage(with: URL(string: imageURL))
            embededViewHeightConstraint.constant = 31/40 * UIScreen.main.bounds.width
            embededImageViewToContainerBottomConstraint.constant = 12
        } else {
            embededViewHeightConstraint.constant = 0
            embededImageViewToContainerBottomConstraint.constant = 0
        }
        
//        self.avatarImageView.sd_setImage(with: post.community.avatarUrl?.url, completed: nil)
        self.likeCounterLabel.text          =   String(describing: (post.votes.upCount ?? 0) + (post.votes.downCount ?? 0))
        self.numberOfCommentsLabel.text     =   "\(post.stats.commentsCount) " + "Comments".localized()
        
        // Handle button
        self.upVoteButton.setImage(UIImage(named: post.votes.hasUpVote ? "icon-up-selected" : "icon-up-default"), for: .normal)
        self.downVoteButton.setImage(UIImage(named: post.votes.hasDownVote ? "icon-down-selected" : "icon-down-default"), for: .normal)
    }
}
