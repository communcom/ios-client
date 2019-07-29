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
    @IBOutlet weak var embedView: UIView!
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
        
        if embededResult?.type == "video",
            let html = embededResult?.html {
            showWebView(with: html)
        } else if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
        } else {
            embedViewHeightConstraint.constant = 0
        }
        
        // Show count label
        commentCountLabel.text = "\(post.stats.commentsCount) " + "Comments count".localized()
        viewCountLabel.text = "\(post.stats.viewCount) " + "Views count".localized()
        voteCountLabel.text = "\(post.votes.upCount ?? 0)"
        
        // Handle button
        self.upVoteButton.setImage(UIImage(named: post.votes.hasUpVote ? "icon-up-selected" : "icon-up-default"), for: .normal)
        self.downVoteButton.setImage(UIImage(named: post.votes.hasDownVote ? "icon-down-selected" : "icon-down-default"), for: .normal)

        // Show title
        postTitleLabel.text = post.content.title
        
        // Show content
        let html = "<span style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\">\(post.content.body.full ?? "")</span>"
        
        contentWebView.loadHTMLString(html, baseURL: nil)
        contentWebView.delegate = self
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.scrollView.bouncesZoom = false
    }
    
    func showWebView(with htmlString: String) {
        var webView: HTMLStringWebView!
        
        if let currentWebView = embedView.subviews.first(where: {$0 is HTMLStringWebView}) as? HTMLStringWebView {
            webView = currentWebView
        } else {
            embedView.removeSubviews()
            webView = HTMLStringWebView()
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            embedView.addSubview(webView)
            webView.topAnchor.constraint(equalTo: embedView.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
            
            webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bouncesZoom = false
            
            embedView.showLoading()
            webView.delegate = self
        }
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func showPhoto(with url: URL) {
        embedView.removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.addTapToViewer()
        
        embedView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: embedView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            self?.hideLoading()
            self?.embedViewHeightConstraint.constant = UIScreen.main.bounds.width * image!.size.height / image!.size.width
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let embedWebView = embedView.subviews.first(where: {$0 is UIWebView}) as? UIWebView,
            webView == embedWebView {
            
            let height  = UIScreen.main.bounds.width * webView.contentHeight / webView.contentWidth
            embedViewHeightConstraint.constant = height
        }
        
        if webView == contentWebView {
            let height  = webView.contentHeight
            contentWebViewHeightConstraint.constant = height + 16
        }
        
        embedView.hideLoading()
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
