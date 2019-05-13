//
//  PostHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class PostHeaderView: UIView {
    // Delegate
    weak var delegate: PostHeaderViewDelegate?
    
    // Media content
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    
    // Reactions
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    // Content
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    
    // Post
    var post: ResponseAPIContentGetPost? {
        didSet {
            guard let post = post else {return}
            setUpWith(post)
        }
    }
    
    func setUpWith(_ post: ResponseAPIContentGetPost) {
        // Show media
        if post.content.embeds.first?.result.type == "video",
            let html = post.content.embeds.first?.result.html {
            webView.loadHTMLString(html, baseURL: nil)
            webViewHeightConstraint.constant = UIScreen.main.bounds.width * 283/375
        } else {
            webViewHeightConstraint.constant = 0
        }
        
        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        let htmlData = NSString(string: post.content.body.full ?? "").data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
            NSAttributedString.DocumentType.html]
        let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                              options: options,
                                                              documentAttributes: nil)
        postContentLabel.attributedText = attributedString
        
        #warning("adjust height of post")
        
        // Notify to delegate to update content
        self.layoutSubviews()
        delegate?.postHeaderViewDidUpdateContent(self)
    }
    
    // Actions
    @IBAction func upvoteButtonDidTouch(_ sender: Any) {
        guard let post = post else {return}
        // TODO: Upvote post
        
        // TODO: Catch result and send result to delegate
        delegate?.didUpVotePost(post)
    }
    
    @IBAction func downVoteButtonDidTouch(_ sender: Any) {
        guard let post = post else {return}
        // TODO: Upvote post
        
        // TODO: Catch result and send result to delegate
        delegate?.didDownVotePost(post)
    }
    
    @IBAction func shareButtonDidTouch(_ sender: Any) {
        guard let post = post else {return}
        // Share post
        delegate?.sharePost(post)
    }
}
