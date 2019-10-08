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
        
        // Show count label
        commentCountLabel.text = "\(post.stats.commentsCount)"
        
        #warning("shareCount or viewCount???")
        shareCountLabel.text = "\(post.stats.viewCount)"
        
        voteCountLabel.text = "\((post.votes.upCount ?? 0) - (post.votes.downCount ?? 0))"
        
        // Handle button
        self.upVoteButton.tintColor =
            post.votes.hasUpVote ? .appMainColor: .lightGray
        self.downVoteButton.tintColor =
            post.votes.hasDownVote ? .appMainColor: .lightGray

        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        // Parse data
        var html = post.content.body.full ?? ""
        
        if let string = post.content.body.full {
            do {
                if let jsonData = string.data(using: .utf8) {
                    let block = try JSONDecoder().decode(ContentBlock.self, from: jsonData)
                    html = block.toHTML(embeds: post.content.embeds.compactMap {$0.result} )
                }
                
                contentWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8)
                
            } catch {
                print(error)
                #warning("MARKDOWN: Remove later")
                let down = Down(markdownString: html)
                if let downHtml = try? down.toHTML(){
                    html = downHtml
                }
                contentWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            }
        }
        
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
