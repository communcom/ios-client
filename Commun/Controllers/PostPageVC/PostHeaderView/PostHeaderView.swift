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
            guard let post = post else {
                setLoading()
                return
            }
            setUpWith(post)
        }
    }
    
    @IBOutlet weak var loadingView: UIView!
    func setLoading() {
        loadingView.isHidden = false
        self.height = 200
        layoutSubviews()
    }
    
    func setUpWith(_ post: ResponseAPIContentGetPost) {
        loadingView.isHidden = true
        // Show media
        if post.content.embeds.first?.result.type == "video",
            let html = post.content.embeds.first?.result.html {
            webView.loadHTMLString(html, baseURL: nil)
            webViewHeightConstraint.constant = UIScreen.main.bounds.width * 283/375
            webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bouncesZoom = false
        } else {
            webViewHeightConstraint.constant = 0
        }
        
        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        let html = "<span style=\"font-family: -apple-system; text-align: justify; font-size: 17\">\(post.content.body.full ?? "")</span>"
        let htmlData = NSString(string: html).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
            NSAttributedString.DocumentType.html]
        let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                              options: options,
                                                              documentAttributes: nil)
        postContentLabel.attributedText = attributedString
        
        // Notify to delegate to update content
        resetHeight()
        self.layoutSubviews()
    }
    
    func resetHeight() {
        var height = webView.height + 112
        height += self.postTitleLabel.height
        height += 32
        height += postContentLabel.attributedText?.size().height ?? 0
        height += 41 + 16 + 26.5 + 16
        self.height = height
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
