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

protocol PostHeaderViewDelegate: class {
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView)
}

class PostHeaderView: UIView, UIWebViewDelegate, PostController {
    let disposeBag = DisposeBag()
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
    @IBOutlet weak var contentWebView: UIWebView!
    
    // Buttons
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    func setLoading() {
        loadingView.isHidden = false
        self.height = 200
        layoutSubviews()
    }
    
    var post: ResponseAPIContentGetPost? 
    
    var showMedia = false
    func setUp() {
        guard let post = post else {
            setLoading()
            return
        }
        
        loadingView.isHidden = true
        // Show media
        if post.content.embeds.first?.result.type == "video",
            let html = post.content.embeds.first?.result.html {
            webView.loadHTMLString(html, baseURL: nil)
            webViewHeightConstraint.constant = UIScreen.main.bounds.width * 283/375
            webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bouncesZoom = false
            webView.delegate = self
            showMedia = true
        } else {
            showMedia = false
            webViewHeightConstraint.constant = 0
        }
        
        // Show count label
        #warning("missing viewsCount + votesCount")
        commentCountLabel.text = "\(post.stats.commentsCount) " + "Comments".localized()
        voteCountLabel.text = post.payout.rShares.stringValue
        
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
        
        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        let html = "<span style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\">\(post.content.body.full ?? "")</span>"
        
        contentWebView.loadHTMLString(html, baseURL: nil)
        contentWebView.delegate = self
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.scrollView.bouncesZoom = false
        
        // Notify to delegate to update content
        layout()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        layout()
        delegate?.headerViewDidLayoutSubviews(self)
    }
    
    func layout() {
        var height: CGFloat = 112.0
        if showMedia {
            height += webViewHeightConstraint.constant
        }
        height += self.postTitleLabel.height
        height += 32
        height += contentWebView.contentHeight
        height += 41 + 16 + 26.5 + 16
        self.height = height
        
        self.layoutSubviews()
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
