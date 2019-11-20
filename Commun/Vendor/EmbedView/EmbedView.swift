//
//  VideoEmbedView.swift
//  Commun
//
//  Created by Artem Shilin on 05.11.2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class EmbedView: UIView {
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var coverImageView: UIImageView!
    @IBOutlet weak private var providerNameLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var providerLabelView: UIView!
    @IBOutlet weak private var titlesView: UIView!

    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.backgroundColor = .black
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = false
        activity.style = .white
        return activity
    }()

    private var content: ResponseAPIContentBlock!

    init(content: ResponseAPIContentBlock) {
        super.init(frame: .zero)
        self.content = content
        self.configureXib()
        self.configure(with: content)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureXib()
    }

    private func configureXib() {
        Bundle.main.loadNibNamed("EmbedView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    private func configure(with content: ResponseAPIContentBlock) {
        coverImageView.removeAllConstraints()
        titleLabel.removeAllConstraints()
        subtitleLabel.removeAllConstraints()
        titlesView.removeAllConstraints()
        titleLabel.numberOfLines = 2
        providerLabelView.isHidden = true

        let inset: CGFloat = 10.0

        var imageUrl = content.attributes?.thumbnail_url
        let isNeedShowTitle = content.attributes?.title != nil
        var isNeedShowProvider = false
        var title: String? = content.attributes?.title
        var subtitle: String?

        if content.type == "video" {
            subtitle = content.attributes?.author
            providerLabelView.isHidden = content.attributes?.provider_name == nil
            providerNameLabel.text = content.attributes?.provider_name
            providerLabelView.isHidden = content.attributes?.provider_name == nil
            isNeedShowProvider = content.attributes?.provider_name != nil
        } else if content.type == "website" {
            subtitle = content.attributes?.url
        } else if content.type == "rich" {
            // TODO: create subview
            title = content.attributes?.description
            titleLabel.numberOfLines = 3
        } else {
            imageUrl = content.content.stringValue
        }

        let isNeedShowImage = true//imageUrl != nil

        subtitleLabel.text = subtitle

        let isNeedShowSubtitle = subtitle != nil

        coverImageView.isHidden = !isNeedShowImage
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))

        if isNeedShowImage {
            if isNeedShowProvider {
                providerLabelView.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
                providerLabelView.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -inset)
            }

            coverImageView.autoPinEdge(toSuperviewEdge: .top)
            coverImageView.autoPinEdge(toSuperviewEdge: .left)
            coverImageView.autoPinEdge(toSuperviewEdge: .right)

            NSLayoutConstraint(item: coverImageView!, attribute: .width, relatedBy: .equal, toItem: coverImageView!, attribute: .height, multiplier: 16.0/9.0, constant: 0).isActive = true
        }

        if let url = URL(string: imageUrl ?? "") {
            if url.path.lowercased().ends(with: ".gif") {
                coverImageView.setImageDetectGif(with: imageUrl!)
            } else {
                coverImageView.sd_setImageCachedError(with: url, completion: nil)
            }
        }

        if isNeedShowTitle {
            titlesView.autoPinEdge(.top, to: .bottom, of: coverImageView)
            titlesView.autoPinEdge(toSuperviewEdge: .left)
            titlesView.autoPinEdge(toSuperviewEdge: .right)
            titlesView.autoPinEdge(toSuperviewEdge: .bottom)
            titlesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))

            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: inset)
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: inset)

            if isNeedShowSubtitle {
                subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 3)
                subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
                subtitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
                subtitleLabel.autoPinEdge(.bottom, to: .bottom, of: titlesView, withOffset: -inset)
            } else {
                titleLabel.autoPinEdge(.bottom, to: .bottom, of: titlesView, withOffset: -inset)
            }
        } else {
            coverImageView.autoPinEdge(toSuperviewEdge: .bottom)
        }

        titleLabel.isHidden = !isNeedShowTitle
        titlesView.isHidden = !isNeedShowTitle

        titleLabel.isHidden = content.attributes?.title == nil
        titleLabel.text = title
        subtitleLabel.isHidden = content.attributes?.url == nil
    }

    @objc private func tapAction() {
        
        if content.type == "video" {
            if let urlString = parseEmbed(content.attributes?.html), let url = URL(string: urlString) {
                coverImageView.isHidden = true
                titlesView.isHidden = true
                addSubview(webView)
                webView.autoPinEdgesToSuperviewEdges()
                addSubview(loadingView)
                loadingView.isHidden = false
                loadingView.autoPinEdgesToSuperviewEdges()
                loadingView.addSubview(activityIndicator)
                activityIndicator.autoPinEdgesToSuperviewEdges()
                activityIndicator.startAnimating()
                webView.load(URLRequest(url: url))
            }
        } else if content.type == "photo" || content.type == "image" {
            coverImageView.openViewer(gesture: nil)
        } else {
            if let url = URL(string: content.attributes?.url ?? "") {
                let safariVC = SFSafariViewController(url: url)
                parentViewController?.present(safariVC, animated: true, completion: nil)
            }
        }
    }

    private func parseEmbed(_ html: String?) -> String? {
        guard let html = html else {
            return nil
        }

        let components = html.components(separatedBy: " ")

        var srcStrings: String? = components.filter { (text) -> Bool in
            return text.contains("src")
        }.first

        srcStrings = srcStrings?.replacingOccurrences(of: "\"", with: "")
        srcStrings = srcStrings?.replacingOccurrences(of: "src=", with: "")
        srcStrings = srcStrings?.replacingOccurrences(of: "//", with: "")

        // for twitch embed
        if let string = srcStrings {
            if !string.contains("http") {
                srcStrings = "https://" + srcStrings!
            }
        }
        return srcStrings
    }
}


extension EmbedView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.isHidden = true
    }
}
