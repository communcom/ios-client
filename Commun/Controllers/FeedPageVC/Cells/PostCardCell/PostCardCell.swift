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

protocol PostCardCellDelegate {
    // Делагат еще буду дорабатывать по мере работы над информацией.
    func didTapMenuButton()
    func didTapUpButton()
    func didTapDownButton()
    func didTapShareButton()
}

class PostCardCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var likeCounterLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfSharesLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var upvoteButton: UIButton!
    
    var delegate: PostCardCellDelegate?
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
        delegate?.didTapMenuButton()
    }
    
    @IBAction func upButtonTap(_ sender: Any) {
        delegate?.didTapUpButton()
    }
    
    @IBAction func downButtonTap(_ sender: Any) {
        delegate?.didTapDownButton()
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        delegate?.didTapShareButton()
    }
}

extension PostCardCell {
    
    func setupFromPost(_ post: ResponseAPIContentGetPost) {
//        self.post = post
        
        self.titleLabel.text = post.content.title
        self.mainTextLabel.text = post.content.body.preview
        
//        self.avatarImageView.sd_setImage(with: post.community.avatarUrl?.url, completed: nil)
//        self.likeCounterLabel.text = "\(post.payout.rShares.stringValue ?? "0")"
        self.numberOfCommentsLabel.text = "\(post.stats.commentsCount) Comments"
    }
    
}
