//
//  AttachmentView.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    private var closeButtonRightConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    lazy var expandButton = UIButton.circleBlack(imageName: "expand")
    lazy var contentView: UIView = UIView(forAutoLayout: ())
    lazy var descriptionView: UIView = {
        let bottomView = UIView(forAutoLayout: ())
        bottomView.backgroundColor = UIColor(hexString: "#F3F5FA")
        return bottomView
    }()
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .bold, numberOfLines: 1)
    lazy var urlLabel = UILabel.with(textSize: 12, textColor: .e2e6e8, numberOfLines: 1)
    
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
        closeButtonRightConstraint = closeButton.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -10)
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
        imageView.addTapToViewer()

        // image
        if let image = image {
            imageView.image = image
        } else if let urlString = url,
            let url = URL(string: urlString) {
            contentView.showLoading()
            imageView.sd_setImageCachedError(with: url) {[weak self] (_, _) in
                self?.contentView.hideLoading()
            }
        }
        
        // set description
        setDescription(url: urlDescription, description: description, absoluteHeight: height)
    }
    
    /// videoAttachment
    func setUp(block: ResponseAPIContentBlock) {
        // modify close button
        if block.type == "rich" || block.type == "embed" {
            closeButtonRightConstraint?.constant = -26
        }
        
        let embedView = EmbedView(content: block)
        addSubview(embedView)
        embedView.autoPinEdgesToSuperviewEdges()
        bringSubviewToFront(closeButton)
        expandButton.isHidden = true
    }
    
    private func setDescription(url: String? = nil, description: String? = nil, absoluteHeight: CGFloat? = nil) {
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
        } else {
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
