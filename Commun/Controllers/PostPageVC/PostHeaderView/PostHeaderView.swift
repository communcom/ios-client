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
    var embededViewFixedHeight: CGFloat? = nil
    
    // Reactions
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    // Content
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var contentWebView: ContentFittingWebView!
    
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
            showMedia = false
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
        
        // Notify to delegate to update content
        layout()
    }
    
    func showWebView(with htmlString: String) {
        showMedia = true
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
        webView.delegate = self
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func showPhoto(with url: URL) {
        showMedia = true
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
            if embededViewFixedHeight == nil {
                let height  = UIScreen.main.bounds.width * webView.contentHeight / webView.contentWidth
                embedViewHeightConstraint.constant = height
                embededViewFixedHeight = height
            } else {
                return
            }
        }
        
        layoutAndNotify()
        
        embedView.hideLoading()
    }
    
    func layoutAndNotify(with keyboardHeight: CGFloat = 0) {
        layout(with: keyboardHeight)
        viewDelegate?.headerViewDidLayoutSubviews(self)
    }
    
    func layout(with keyboardHeight: CGFloat = 0) {
        var height: CGFloat = 112.0
        if !showMedia {
            embedViewHeightConstraint.constant = 0
        }
        
        height += embedViewHeightConstraint.constant
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
