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
        
        let embeds = post.content.embeds
        
        if embeds.count > 0,
            let imageURL = embeds[0].result?.thumbnail_url {
            embededImageView.sd_setImage(with: URL(string: imageURL))
            embededViewHeightConstraint.constant = 31/40 * UIScreen.main.bounds.width
            embededImageViewToContainerBottomConstraint.constant = 12
        } else {
            embededViewHeightConstraint.constant = 0
            embededImageViewToContainerBottomConstraint.constant = 0
        }
        
//        self.avatarImageView.sd_setImage(with: post.community.avatarUrl?.url, completed: nil)
        #warning("change this numbers later")
        self.likeCounterLabel.text = "\(post.payout.rShares?.stringValue ?? "0")"
        
        self.numberOfCommentsLabel.text = "\(post.stats.commentsCount) " + "Comments".localized()
        
        // Handle button
        var upVoteImageName = "Up"
        if post.votes.hasUpVote {
            upVoteImageName = "UpSelected"
        }
        upVoteButton.setImage(UIImage(named: upVoteImageName), for: .normal)
        
        var downVoteImageName = "Down"
        if post.votes.hasDownVote {
            downVoteImageName = "DownSelected"
        }
        downVoteButton.setImage(UIImage(named: downVoteImageName), for: .normal)
    }
    
}
