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
    @IBOutlet weak var contentWebView: UIWebView!
    
    // Buttons
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var fixedHeight: CGFloat?
    
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
        // Observe keyboard
        UIResponder.keyboardHeightObservable
            .subscribe(onNext: {keyboardHeight in
                self.layoutAndNotify(with: keyboardHeight)
            })
            .disposed(by: disposeBag)
    }
    
    var showMedia = false
    func setUp(with post: ResponseAPIContentGetPost?) {
        self.post = post
        guard let post = post else {
            showLoading()
            self.height = 200
            layoutSubviews()
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
            showEmbed(false)
        }
        
        // Show count label
        #warning("missing viewsCount + votesCount")
        commentCountLabel.text = "\(post.stats.commentsCount) " + "Comments".localized()
        voteCountLabel.text = post.payout.rShares?.stringValue ?? "0"
        
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
    
    func showEmbed(_ show: Bool) {
        self.embedViewHeightConstraint.constant = show ? UIScreen.main.bounds.width * 283/375 : 0
        self.showMedia = show
    }
    
    func showWebView(with htmlString: String) {
        showEmbed(true)
        embedView.removeSubviews()
        let webView = UIWebView()
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
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        webView.delegate = self
    }
    
    func showPhoto(with url: URL) {
        showEmbed(true)
        embedView.removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        embedView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: embedView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
        
        imageView.showLoading()

        imageView.sd_setImage(with: url) { (_, _, _, _) in
            imageView.hideLoading()
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        layoutAndNotify()
        if webView == contentWebView {
            fixedHeight = self.height
        }
        embedView.hideLoading()
    }
    
    func layoutAndNotify(with keyboardHeight: CGFloat = 0) {
        layout(with: keyboardHeight)
        viewDelegate?.headerViewDidLayoutSubviews(self)
    }
    
    func layout(with keyboardHeight: CGFloat = 0) {
        if let height = fixedHeight {
            self.height = height
            self.layoutSubviews()
            return
        }
        var height: CGFloat = 112.0
        if showMedia {
            height += embedViewHeightConstraint.constant
        }
        height += self.postTitleLabel.height
        height += 32
        height += contentWebView.contentHeight
        height -= keyboardHeight
        
        height += 41 + 16 + 26.5 + 16
        
        if self.height == height {return}
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
