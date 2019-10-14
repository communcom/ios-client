//
//  AttachmentView.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol AttachmentViewDelegate: class {
    func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView)
}

class AttachmentView: UIView {
    // MARK: - Properties
    weak var delegate: AttachmentViewDelegate?
    var showCloseButton = false {
        didSet {
            closeButton.isHidden = !showCloseButton
        }
    }
    
    // MARK: - Subviews
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
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
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        // pin closeButton
        addSubview(closeButton)
        closeButton.autoPinEdge(.top, to: .top, of: imageView, withOffset: 10)
        closeButton.autoPinEdge(.trailing, to: .trailing, of: imageView, withOffset: -10)
    }
    
    func setUp(image: UIImage?, url: String? = nil, description: String? = nil) {
        
        // remove all subviews
        imageView.removeConstraintToSuperView(withAttribute: .bottom)
        descriptionView.removeSubviews()
        descriptionView.removeAllConstraints()
        descriptionView.removeFromSuperview()
        
        // image
        imageView.image = image
        
        // description
        var url = url
        var description = description
        
        if url?.trimmed.isEmpty ?? true {url = nil}
        if description?.trimmed.isEmpty ?? true {description = nil}
        
        if url == nil && description == nil {
            imageView.autoPinEdge(toSuperviewEdge: .bottom)
        }
        else {
            addSubview(descriptionView)
            titleLabel.text = description
            urlLabel.text = url
            
            if description != nil && url == nil {
                descriptionView.addSubview(titleLabel)
                titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
                descriptionView.autoSetDimension(.height, toSize: 38)
            }
            
            if description == nil && url != nil {
                descriptionView.addSubview(urlLabel)
                urlLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
                descriptionView.autoSetDimension(.height, toSize: 34)
            }
            
            if description != nil && url != nil {
                descriptionView.addSubview(titleLabel)
                descriptionView.addSubview(urlLabel)
                titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16), excludingEdge: .bottom)
                urlLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16), excludingEdge: .top)
                descriptionView.autoSetDimension(.height, toSize: 55)
            }
            
            descriptionView.autoPinEdge(.top, to: .bottom, of: imageView)
            descriptionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
        }
    }
    
}
