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

protocol PostHeaderViewDelegate: class {
    func headerViewDidLayoutSubviews(_ headerView: PostHeaderView)
}

class PostHeaderView: UIView, UIWebViewDelegate, PostController {
    let disposeBag = DisposeBag()
    // Delegate
    weak var viewDelegate: PostHeaderViewDelegate?
    
    // Media content
    @IBOutlet weak var embedView: EmbededView!
    @IBOutlet weak var embedViewHeightConstraint: NSLayoutConstraint!
    
    // Reactions
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    // Content
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var contentWebView: HTMLStringWebView!
    @IBOutlet weak var contentWebViewHeightConstraint: NSLayoutConstraint!
    
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
        // Show media
        let embededResult = post.content.embeds.first?.result
        embedView.setUpWithEmbeded(embededResult)
        
        // Show count label
        commentCountLabel.text = "\(post.stats.commentsCount) " + "comments count".localized()
        viewCountLabel.text = "\(post.stats.viewCount) " + "views count".localized()
        voteCountLabel.text = "\(post.votes.upCount ?? 0)"
        
        // Handle button
        self.upVoteButton.setImage(UIImage(named: post.votes.hasUpVote ? "icon-up-selected" : "icon-up-default"), for: .normal)
        self.downVoteButton.setImage(UIImage(named: post.votes.hasDownVote ? "icon-down-selected" : "icon-down-default"), for: .normal)

        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        let html = "<section style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\"> \(post.content.body.full ?? "") </section>"
        
        contentWebView.loadHTMLString(html, baseURL: nil)
        contentWebView.delegate = self
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.scrollView.bouncesZoom = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.showLoading()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.hideLoading()
        let height  = webView.contentHeight
        contentWebViewHeightConstraint.constant = height + 16
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
