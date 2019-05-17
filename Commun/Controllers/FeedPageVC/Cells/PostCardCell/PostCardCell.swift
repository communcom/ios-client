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


class PostCardCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var likeCounterLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfSharesLabel: UILabel!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    @IBOutlet weak var embededImageView: UIImageView!
    @IBOutlet weak var embededViewHeightConstraint: NSLayoutConstraint!
    var delegate: PostActionsDelegate?
    var post: ResponseAPIContentGetPost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        avatarImageView.layer.cornerRadius = avatarImageView.height / 2
        avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func menuButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.didTapMenuButton(forPost: post)
        }
    }
    
    @IBAction func upButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.didTapUpButton(forPost: post)
        }
    }
    
    @IBAction func downButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.didTapDownButton(forPost: post)
        }
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        if let post = post {
            delegate?.didTapShareButton(forPost: post)
        }
    }
}

extension PostCardCell {
    
    func setupFromPost(_ post: ResponseAPIContentGetPost) {
//        self.post = post
        self.avatarImageView.setAvatar(urlString: post.community.avatarUrl, namePlaceHolder: post.community.name)
        
        self.titleLabel.text = post.content.title
        self.timeAgoLabel.text = Date.timeAgo(string: post.meta.time)
        
        self.authorNameLabel.text = "by".localized() + " " + (post.author?.username ?? post.author?.userId ?? "")
        
        self.mainTextLabel.text = post.content.body.preview
        self.accessibilityLabel = "PostCardCell"
        
        let embeds = post.content.embeds
        
        if embeds.count > 0,
            let imageURL = embeds[0].result.thumbnail_url {
            embededImageView.sd_setImage(with: URL(string: imageURL))
            embededViewHeightConstraint.constant = 31/40 * UIScreen.main.bounds.width
        } else {
            embededViewHeightConstraint.constant = 0
        }
        
//        self.avatarImageView.sd_setImage(with: post.community.avatarUrl?.url, completed: nil)
        #warning("change this numbers later")
        self.likeCounterLabel.text = "\(post.payout.rShares.stringValue ?? "0")"
        
        self.numberOfCommentsLabel.text = "\(post.stats.commentsCount) " + "Comments".localized()
        
        // Handle button
        var upVoteImageName = "Up"
        if post.votes.hasUpVote {
            upVoteImageName = "UpSelected"
        }
        upvoteButton.setImage(UIImage(named: upVoteImageName), for: .normal)
        
        var downVoteImageName = "Down"
        if post.votes.hasDownVote {
            downVoteImageName = "DownSelected"
        }
        downVoteButton.setImage(UIImage(named: downVoteImageName), for: .normal)
    }
    
}
