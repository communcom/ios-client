//
//  VideoEmbedView.swift
//  Commun
//
//  Created by Artem Shilin on 05.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import AVKit

class EmbedView: UIView {
    // MARK: - UI Property
    private lazy var coverImageView: UIImageView = UIImageView(forAutoLayout: ())

    private lazy var providerNameLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .appBlackColor
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .appGrayColor
        return label
    }()

    private lazy var providerLabelView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()

    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBlackColor
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

    private lazy var contentView: UIView = UIView(forAutoLayout: ())
    private lazy var titlesView: UIView = UIView(forAutoLayout: ())

    // MARK: - Helper Property
    private var content: ResponseAPIContentBlock!
    private var videoLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isPostDetail = false

    // MARK: - View Lifecycle
    init(content: ResponseAPIContentBlock, isPostDetail: Bool = false) {
        super.init(frame: .zero)
        self.isPostDetail = isPostDetail
        self.content = content
        self.addSubviews()
        self.configure(with: content)
    }
    
    init(localImage: UIImage) {
        super.init(frame: .zero)
        self.content = ResponseAPIContentBlock(id: 0, type: "image", attributes: nil, content: ResponseAPIContentBlockContent.string(""))
        self.addSubviews()
        self.configure(with: localImage)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer?.frame = bounds
    }

    // MARK: - Functions
    private func addSubviews() {
        addSubview(coverImageView)
        addSubview(titlesView)
        titlesView.addSubview(titleLabel)
        titlesView.addSubview(subtitleLabel)

        coverImageView.addSubview(providerLabelView)
        providerLabelView.addSubview(providerNameLabel)

        providerNameLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))

        coverImageView.autoPinEdge(toSuperviewMargin: .right, withInset: 10)
        coverImageView.autoPinEdge(toSuperviewMargin: .bottom, withInset: 10)
    }
    
    private func configure(with localImage: UIImage) {
        coverImageView.isHidden = false
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        coverImageView.autoPinEdge(toSuperviewEdge: .top)
        coverImageView.autoPinEdge(toSuperviewEdge: .left)
        coverImageView.autoPinEdge(toSuperviewEdge: .right)

        NSLayoutConstraint(item: coverImageView, attribute: .width, relatedBy: .equal, toItem: coverImageView, attribute: .height, multiplier: 16/9, constant: 0).isActive = true
        
        coverImageView.image = localImage
        
        titleLabel.removeAllConstraints()
        subtitleLabel.removeAllConstraints()
        titlesView.removeAllConstraints()
        
        providerLabelView.isHidden = true
        titlesView.isHidden = true
        
        coverImageView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func configure(with content: ResponseAPIContentBlock) {
        titleLabel.numberOfLines = 1
        coverImageView.removeAllConstraints()
        titleLabel.removeAllConstraints()
        subtitleLabel.removeAllConstraints()
        titlesView.removeAllConstraints()
        providerLabelView.isHidden = true
        titlesView.isHidden = false

        if content.type == "rich" || content.type == "embed" {
            let view = InstagramView(content: content, isPostDetail: isPostDetail)
            addSubview(view)
            view.autoPinEdgesToSuperviewEdges()
            return
        }

        backgroundColor = .appLightGrayColor
        let insetX: CGFloat = 16
        let insetY: CGFloat = 10.0

        var imageUrl = content.attributes?.thumbnailUrl
        let isNeedShowTitle = content.attributes?.title != nil
        var isNeedShowProvider = false
        let title: String? = content.attributes?.title
        var subtitle: String?

        if content.type == "video" {
            if let videoUrl = content.attributes?.url, videoUrl.lowercased().ends(with: ".mp4"),
                let videoURL = URL(string: videoUrl) {
                titlesView.isHidden = true

                backgroundColor = .black
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 16/9, constant: 0).isActive = true

                player = AVPlayer(url: videoURL)
                videoLayer = AVPlayerLayer(player: player)
                videoLayer!.frame = bounds
                layer.addSublayer(videoLayer!)
                player?.play()
                return
            }

            coverImageView.isUserInteractionEnabled = false
            subtitle = content.attributes?.author
            providerLabelView.isHidden = content.attributes?.providerName == nil
            providerNameLabel.text = content.attributes?.providerName?.uppercaseFirst
            providerLabelView.isHidden = content.attributes?.providerName == nil
            isNeedShowProvider = content.attributes?.providerName != nil
        } else if content.type == "website", let url = URL(string: content.attributes?.url ?? "") {
            subtitle = InstagramView.getRightHostName(url: url)
        } else {
            imageUrl = content.content.stringValue
        }

        let isNeedShowImage = imageUrl != nil

        subtitleLabel.text = subtitle

        let isNeedShowSubtitle = subtitle != nil

        coverImageView.isHidden = !isNeedShowImage
        coverImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))

        if isNeedShowImage {

            let width: CGFloat = CGFloat(content.attributes?.width ?? content.attributes?.thumbnailWidth ?? 1280)
            let height: CGFloat = CGFloat(content.attributes?.height ?? content.attributes?.thumbnailHeight ?? 720)

            let screenWidth = UIScreen.main.bounds.width

            var newHeight = screenWidth / width * height

            if newHeight > 700 && !isPostDetail {
                newHeight = 640
            }

            if isNeedShowProvider {
                providerLabelView.autoPinEdge(toSuperviewEdge: .right, withInset: insetX)
                providerLabelView.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -insetY)
            }

            coverImageView.autoPinEdge(toSuperviewEdge: .top)
            coverImageView.autoPinEdge(toSuperviewEdge: .left)
            coverImageView.autoPinEdge(toSuperviewEdge: .right)

            NSLayoutConstraint(item: coverImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight).isActive = true
        }

        if let imageUrl = imageUrl {
            coverImageView.setImageDetectGif(with: imageUrl)
            coverImageView.addTapToViewer()
        }

        if isNeedShowTitle {
            if isNeedShowImage {
                titlesView.autoPinEdge(.top, to: .bottom, of: coverImageView)
            } else {
                titlesView.autoPinEdge(toSuperviewEdge: .top)
            }
            titlesView.autoPinEdge(toSuperviewEdge: .left)
            titlesView.autoPinEdge(toSuperviewEdge: .right)
            titlesView.autoPinEdge(toSuperviewEdge: .bottom)
            titlesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))

            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: insetY)
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: insetX)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: insetX)

            if isNeedShowSubtitle {
                subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 3)
                subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: insetX)
                subtitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: insetX)
                subtitleLabel.autoPinEdge(.bottom, to: .bottom, of: titlesView, withOffset: -insetY)
            } else {
                titleLabel.autoPinEdge(.bottom, to: .bottom, of: titlesView, withOffset: -insetY)
            }
        } else {
            coverImageView.autoPinEdge(toSuperviewEdge: .bottom)
        }

        titleLabel.isHidden = !isNeedShowTitle
        titlesView.isHidden = !isNeedShowTitle

        titleLabel.isHidden = content.attributes?.title == nil
        titleLabel.text = title
        subtitleLabel.isHidden = content.attributes?.url == nil

        self.isUserInteractionEnabled = false
        coverImageView.isUserInteractionEnabled = false

        if isPostDetail {
            self.isUserInteractionEnabled = true
            coverImageView.isUserInteractionEnabled = true

            if content.type == "video" {
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 16/9, constant: 0).isActive = true
                coverImageView.isHidden = true
                tapAction()
            }

            return
        }
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
        } else {
            if let url = URL(string: content.attributes?.url ?? "") {
                parentViewController?.handleUrl(url: url)
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
