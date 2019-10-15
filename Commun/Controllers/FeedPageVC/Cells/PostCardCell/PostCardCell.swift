//
//  PostCardCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
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
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var embededViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridViewToContainerBottomConstraint: NSLayoutConstraint!
    var post: ResponseAPIContentGetPost?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // http://adamborek.com/top-7-rxswift-mistakes/
        // have to reset disposeBag when reusing cell
        disposeBag = DisposeBag()
        
        observePostChange()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        avatarImageView.layer.cornerRadius = avatarImageView.height / 2
        avatarImageView.clipsToBounds = true
        
        // add gesture to authorNameLabel
        let tap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped(_:)))
        authorNameLabel.isUserInteractionEnabled = true
        authorNameLabel.addGestureRecognizer(tap)
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
    
    @objc func userNameTapped(_ sender: UITapGestureRecognizer) {
        guard let userId = post?.author?.userId else {return}
        parentViewController?.showProfileWithUserId(userId)
    }
}

extension PostCardCell {
    
    func setUp(with post: ResponseAPIContentGetPost?) {
        guard let post = post else {return}
        self.post = post
        self.avatarImageView.setAvatar(urlString: post.community.avatarUrl, namePlaceHolder: post.community.name ?? post.community.communityId ?? "C")
        
        self.titleLabel.text = post.community.name ?? post.community.communityId
        self.timeAgoLabel.text = Date.timeAgo(string: post.meta.creationTime)
        
        self.authorNameLabel.text = post.author?.username ?? post.author?.userId ?? ""
        
        self.mainTextLabel.text = post.content.attributes?.title
        self.accessibilityLabel = "PostCardCell"
        
        let embeds = post.attachments
        if embeds.isEmpty {
            embededViewHeightConstraint.constant = 0
            gridViewToContainerBottomConstraint.constant = 0
        }
        else {
            gridView.setUp(embeds: embeds)
            embededViewHeightConstraint.constant = 31/40 * UIScreen.main.bounds.width
            gridViewToContainerBottomConstraint.constant = 12
        }
        
//        self.avatarImageView.sd_setImage(with: post.community.avatarUrl?.url, completed: nil)
        #warning("change this number later")
        self.likeCounterLabel.text          =   "\((post.votes.upCount ?? 0) - (post.votes.downCount ?? 0))"
        self.numberOfCommentsLabel.text     =   "\(post.stats?.commentsCount ?? 0)"
        self.numberOfViewsLabel.text        =   "\(post.stats?.viewCount ?? 0)"
        
        // Handle button
        self.upVoteButton.tintColor = post.votes.hasUpVote ?? false ? .appMainColor: .lightGray
        self.downVoteButton.tintColor = post.votes.hasDownVote ?? false ? .appMainColor: .lightGray
    }
}
