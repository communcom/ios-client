//
//  PreviewView.swift
//  Commun
//
//  Created by Chung Tran on 8/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftLinkPreview

class PreviewView: UIView {
    // MARK: - Enum
    enum MediaType {
        case image(image: UIImage?, url: String?)
        case linkFromText(text: String)
    }
    
    // MARK: - Properties
    var heightConstraint: NSLayoutConstraint!
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Close"), for: .normal)
        
        // constraint
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)
//        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        heightConstraint = constraints.first {$0.firstAttribute == .height}
    }
    
    // MARK: - Methods
    func setUp(mediaType: MediaType) {
        // show loading
        showLoading()
        
        // completion
        let completion: (Error?)->Void = { [weak self] error in
            self?.hideLoading()
            self?.showFloatingButtons()
        }
        
        switch mediaType {
        case .image(let image, let url):
            showImageWithImage(image, orUrl: url, completion: completion)
        case .linkFromText(let text):
            showLinkPreviewWithUrlFromText(text, completion: completion)
        }
    }
    
    func showFloatingButtons() {
        addSubview(closeButton)
        
        // constraint
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
    func showImageWithImage(_ image: UIImage?, orUrl url: String?, completion: ((Error?)->Void)? = nil) {
        removeSubviews()
        // Create image View
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add imageView
        addSubview(imageView)
        
        // Set constrain
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        // Set image
        if let image = image {
            imageView.image = image
            completion?(nil)
        } else if let urlString = url,
            let url = URL(string: urlString){
            imageView.sd_setImage(with: url) { (image, error, _, _) in
                completion?(error)
            }
        }
    }
    
    func showLinkPreviewWithUrlFromText(_ text: String, completion: ((Error?)->Void)? = nil) {
        removeSubviews()
        
        // Get preview
        let slp = SwiftLinkPreview(cache: InMemoryCache())
        
        // handlers
        let successHandler: ((Response) -> Void)  = {[weak self] response in
            guard let strongSelf = self else {return}
            // imageView
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            strongSelf.addSubview(imageView)
            
            // bottom views
            let bottomView = UIView()
            bottomView.translatesAutoresizingMaskIntoConstraints = false
            bottomView.backgroundColor = UIColor(hexString: "#F5F5F5")
            strongSelf.addSubview(bottomView)
            
            // bottom subviews
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = .boldSystemFont(ofSize: 17)
            titleLabel.numberOfLines = 2
            bottomView.addSubview(titleLabel)
            
            let urlLabel = UILabel()
            urlLabel.translatesAutoresizingMaskIntoConstraints = false
            urlLabel.font = .systemFont(ofSize: 15)
            urlLabel.textColor = .lightGray
            bottomView.addSubview(urlLabel)
            
            // bottom inner constraints
            titleLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16).isActive = true
            
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            urlLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16).isActive = true
            urlLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16).isActive = true
            urlLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -16).isActive = true
            
            // setup constraints
            imageView.topAnchor.constraint(equalTo: strongSelf.topAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: strongSelf.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: strongSelf.trailingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
            
            bottomView.leadingAnchor.constraint(equalTo: strongSelf.leadingAnchor).isActive = true
            bottomView.trailingAnchor.constraint(equalTo: strongSelf.trailingAnchor).isActive = true
            bottomView.bottomAnchor.constraint(equalTo: strongSelf.bottomAnchor).isActive = true
            
            if let imageUrlString = response.image,
                let imageUrl = URL(string: imageUrlString) {
                imageView.sd_setImage(with: imageUrl)
            }
            
            titleLabel.text = response.description
            urlLabel.text = response.canonicalUrl
            
            strongSelf.bringSubviewToFront(strongSelf.closeButton)
            completion?(nil)
        }
        
        let errorHandler: ((PreviewError) -> Void) = {error in
            // TODO:
            completion?(error)
        }
        
        if let cached = slp.cache.slp_getCachedResponse(url: text) {
            // Do whatever with the cached response
            successHandler(cached)
        } else {
            // Perform preview otherwise
            slp.preview(text, onSuccess: successHandler, onError: errorHandler)
        }
    }
}
