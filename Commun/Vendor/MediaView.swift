//
//  MediaView.swift
//  Commun
//
//  Created by Chung Tran on 8/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SwiftLinkPreview

protocol MediaViewDelegate: class {
    func mediaViewCloseButtonDidTouch()
}

class MediaView: UIView {
    // MARK: - Variables
    var cancelablePreview: Cancellable?
    weak var delegate: MediaViewDelegate?
    var showCloseButton = true {
        didSet {
            closeButton.isHidden = !showCloseButton
        }
    }
    
    // MARK: - Subviews
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Close"), for: .normal)
        
        // constraint
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return button
    }()
    
    lazy var imageView: UIImageView = {
        // Create image View
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var descriptionView: UIView = {
        // bottom views
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = UIColor(hexString: "#F5F5F5")
        return bottomView
    }()
    
    lazy var titleLabel: UILabel = {
        // bottom subviews
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    lazy var urlLabel: UILabel = {
        let urlLabel = UILabel()
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.font = .systemFont(ofSize: 15)
        urlLabel.textColor = .lightGray
        return urlLabel
    }()
    
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
        imageView.contentMode = .scaleToFill
        
        // subviews
        addSubview(imageView)
        addSubview(descriptionView)
        addSubview(closeButton)
    
        // descriptionView's subview
        descriptionView.addSubview(titleLabel)
        descriptionView.addSubview(urlLabel)
        
        // imageView's constraints
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: descriptionView.topAnchor).isActive = true
        
        // descriptionView's constraints
        descriptionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        descriptionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        descriptionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // layout descriptionView
        titleLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16).isActive = true
        
        urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        urlLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16).isActive = true
        urlLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16).isActive = true
        urlLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -16).isActive = true
        
        // closeButton
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        closeButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
    }
    
    // MARK: - Methods
    @objc func clear() {
        cancelablePreview?.cancel()
        delegate?.mediaViewCloseButtonDidTouch()
    }
    
    func setUpWithAttachmentType(
        _ attachmentType: TextAttachment.AttachmentType,
        completion: ((Error?)->Void)? = nil
    ) {
        switch attachmentType {
        case .image(let image, let url, let description):
            // Set description
            titleLabel.text = description
            urlLabel.text = url
            
            // Set image
            if let image = image {
                imageView.image = image
                completion?(nil)
            } else if let urlString = url,
                let url = URL(string: urlString){
                imageView.showLoader()
                imageView.sd_setImage(with: url) { [weak self] (image, error, _, _) in
                    self?.imageView.hideLoader()
                    if error != nil {
                        self?.imageView.image = UIImage(named: "image-not-found")
                    }
                    completion?(error)
                }
            }
        case .url(let url, _):
            // Get preview
            let slp = SwiftLinkPreview(cache: InMemoryCache())
            
            // handlers
            let successHandler: ((Response) -> Void)  = {[weak self] response in
                guard let strongSelf = self else {return}
                
                if let imageUrlString = response.image,
                    let imageUrl = URL(string: imageUrlString) {
                    strongSelf.imageView.sd_setImageCachedError(with: imageUrl, completion: completion)
                }
                
                strongSelf.titleLabel.text = response.title
                strongSelf.urlLabel.text = response.canonicalUrl
            }
            
            let errorHandler: ((PreviewError) -> Void) = {error in
                completion?(error)
            }
            
            if let cached = slp.cache.slp_getCachedResponse(url: url) {
                // Do whatever with the cached response
                successHandler(cached)
            } else {
                // Perform preview otherwise
                cancelablePreview = slp.preview(url, onSuccess: successHandler, onError: errorHandler)
            }
        }
    }
}
