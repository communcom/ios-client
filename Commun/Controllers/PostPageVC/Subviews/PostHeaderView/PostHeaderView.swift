//
//  PostHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 13/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift
import WebKit
import Down

protocol PostHeaderViewDelegate: class {
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView)
}

class PostHeaderView: UIView, UIWebViewDelegate, PostController {
    let disposeBag = DisposeBag()
    // Delegate
    weak var viewDelegate: PostHeaderViewDelegate?
    
    // Reactions
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var shareCountLabel: UILabel!
    
    // Content
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var titleToContentTextViewSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTextView: PostHeaderTextView!
    
    // Buttons
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var post: ResponseAPIContentGetPost?
    
    // Inititalizer
    override required init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        observePostChange()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewDelegate?.headerViewDidLayoutSubviews(self)
    }
    
    func setUp(with post: ResponseAPIContentGetPost?) {
        self.post = post
        guard let post = post else {
            showLoading()
            return
        }
        hideLoading()
        
        if post.document?.attributes?.type == "article" {
            // Show title
            postTitleLabel.text = post.document?.attributes?.title
            
            titleToContentTextViewSpaceConstraint.constant = 20
        }
        else {
            postTitleLabel.text = nil
            titleToContentTextViewSpaceConstraint.constant = 0
        }
        
        // Show count label
        commentCountLabel.text = "\(post.stats?.commentsCount ?? 0)"
        
        #warning("shareCount or viewCount???")
        shareCountLabel.text = "\(post.stats?.viewCount ?? 0)"
        
        voteCountLabel.text = "\((post.votes.upCount ?? 0) - (post.votes.downCount ?? 0))"
        
        // Handle button
        self.upVoteButton.tintColor =
            post.votes.hasUpVote ?? false ? .appMainColor: .lightGray
        self.downVoteButton.tintColor =
            post.votes.hasDownVote ?? false ? .appMainColor: .lightGray
        
        // Show content
        // Parse data
        let attributedString = post.document?.toAttributedString(
            currentAttributes: contentTextView.defaultAttributes,
            attachmentSize: contentTextView.attachmentSize)
        
        contentTextView.attributedText = attributedString
        layoutSubviews()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let webView = webView as? HTMLStringWebView {
            return webView.webView(webView, shouldStartLoadWith: request, navigationType: navigationType)
        }
        if navigationType == .linkClicked {return false}
        return true
    }
    
    @IBAction func upVoteButtonDidTouch(_ sender: Any) {
        upVote()
    }
    
    @IBAction func downVoteButtonDidTouch(_ sender: Any) {
        downVote()
    }
    
    @IBAction func shareButtonDidTouch(_ sender: Any) {
        sharePost()
    }
}
