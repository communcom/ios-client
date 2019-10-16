//
//  AttachmentView.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import WebKit

protocol AttachmentViewDelegate: class {
    func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView)
    func attachmentViewExpandButtonDidTouch(_ attachmentView: AttachmentView)
}

class AttachmentView: UIView {
    // MARK: - Properties
    weak var delegate: AttachmentViewDelegate?
    var showCloseButton = false {
        didSet {
            closeButton.isHidden = !showCloseButton
        }
    }
    weak var attachment: TextAttachment?
    
    // MARK: - Subviews
    lazy var closeButton = UIButton.circleBlack(imageName: "close-x")
    lazy var expandButton = UIButton.circleBlack(imageName: "expand")
    lazy var contentView: UIView = UIView(forAutoLayout: ())
    lazy var descriptionView: UIView = {
        let bottomView = UIView(forAutoLayout: ())
        bottomView.backgroundColor = UIColor(hexString: "#F3F5FA")
        return bottomView
    }()
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .bold, numberOfLines: 1)
    lazy var urlLabel = UILabel.with(textSize: 12, textColor: .lightGray, numberOfLines: 1)
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        // setup apperance
        backgroundColor = .white
        
        // pin imageView
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        // pin closeButton
        addSubview(closeButton)
        closeButton.autoPinEdge(.top, to: .top, of: contentView, withOffset: 10)
        closeButton.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -10)
        closeButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        
        // pin expandButton
        addSubview(expandButton)
        expandButton.autoPinEdge(.top, to: .bottom, of: contentView, withOffset: -34)
        expandButton.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -10)
        expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
    }
    
    // MARK: - Methods
    @objc func clear() {
        delegate?.attachmentViewCloseButtonDidTouch(self)
    }
    
    @objc func expand() {
        delegate?.attachmentViewExpandButtonDidTouch(self)
    }
    
    func clean() {
        // remove all subviews
        contentView.removeSubviews()
        contentView.removeConstraintToSuperView(withAttribute: .bottom)
        descriptionView.removeSubviews()
        descriptionView.removeAllConstraints()
        descriptionView.removeFromSuperview()
    }
    
    /// imageAttachment
    func setUp(image: UIImage?, url: String? = nil, urlDescription: String? = nil, description: String? = nil, absoluteHeight: CGFloat? = nil) {
        // clean views
        clean()
        
        // create imageView
        let imageView = UIImageView(forAutoLayout: ())
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // layout
        contentView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        
        // image
        if let image = image {
            imageView.image = image
        }
        else if let urlString = url,
            let url = URL(string: urlString)
        {
            contentView.showLoading()
            imageView.sd_setImageCachedError(with: url) {[weak self] (error, image) in
                self?.contentView.hideLoading()
            }
        }
        
        // set description
        setDescription(url: urlDescription, description: description, absoluteHeight: height)
    }
    
    /// videoAttachment
    func setUp(block: ResponseAPIContentBlock, absoluteHeight: CGFloat? = nil) {
        if block.type == "image" {
            setUp(image: nil, url: block.content.stringValue ?? block.attributes?.url, description: block.attributes?.title ?? block.attributes?.description, absoluteHeight: absoluteHeight)
            return
        }
        
        if block.type == "website" {
            setUp(image: nil, url: block.attributes?.thumbnail_url ?? block.attributes?.url, urlDescription: block.content.stringValue, description: block.attributes?.title ?? block.attributes?.description, absoluteHeight: absoluteHeight)
            return
        }
        
        if block.type == "video" {
            let webConfiguration = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.configureForAutoLayout()
            webView.scrollView.isScrollEnabled = false
            
            contentView.addSubview(webView)
            webView.autoPinEdgesToSuperviewEdges()
            
            if let string = block.attributes?.html {
                let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><link rel=\"stylesheet\" type=\"text/css\" href=\"HTMLStringWebView.css\"></HEAD><BODY><section style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\">"
                let htmlEnd = " </section></BODY></HTML>"
                let html = htmlStart + string + htmlEnd
                webView.loadHTMLString(html, baseURL: nil)
            }
            
            setDescription(url: block.content.stringValue ?? block.attributes?.url, description: block.attributes?.title ?? block.attributes?.description, absoluteHeight: absoluteHeight)
        }
    }
    
    func setDescription(url: String? = nil, description: String? = nil, absoluteHeight: CGFloat? = nil) {
        // description
        var url = url
        var description = description
        
        if url?.trimmed.isEmpty ?? true {url = nil}
        if description?.trimmed.isEmpty ?? true {description = nil}
        
        if url == nil && description == nil {
            contentView.autoPinEdge(toSuperviewEdge: .bottom)
            if let height = absoluteHeight {
                contentView.autoSetDimension(.height, toSize: height)
            }
        }
        else {
            addSubview(descriptionView)
            titleLabel.text = description
            urlLabel.text = url
            
            var descriptionHeight: CGFloat = 0
            
            if description != nil && url == nil {
                descriptionView.addSubview(titleLabel)
                titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
                descriptionHeight = 38
            }
            
            if description == nil && url != nil {
                descriptionView.addSubview(urlLabel)
                urlLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
                descriptionHeight = 34
            }
            
            if description != nil && url != nil {
                descriptionView.addSubview(titleLabel)
                descriptionView.addSubview(urlLabel)
                titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16), excludingEdge: .bottom)
                urlLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16), excludingEdge: .top)
                descriptionHeight = 55
            }
            
            descriptionView.autoSetDimension(.height, toSize: descriptionHeight)
            if let height = absoluteHeight {
                contentView.autoSetDimension(.height, toSize: height - descriptionHeight)
            }
            
            descriptionView.autoPinEdge(.top, to: .bottom, of: contentView)
            descriptionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
        }
    }
}
