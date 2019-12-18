//
//  ArticlePostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

final class ArticlePostCell: PostCell {
    // MARK: - Constants
    
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())

        let blackoutView = UIView()
        imageView.addSubview(blackoutView)
        blackoutView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        blackoutView.autoPinEdgesToSuperviewEdges()

        imageView.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.with(textSize: 21, weight: .bold, textColor: .white, numberOfLines: 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var readButton: UIView = {
        let button = UIView(height: 34)
        button.backgroundColor = .white
        button.cornerRadius = 17
        
        let imageView = UIImageView(width: 24, height: 24)
        imageView.image = UIImage(named: "fire")
        button.addSubview(imageView)
        
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
        
        let label = UILabel.with(text: "read".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        button.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 12)
        
        label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 6)
        
        return button
    }()

    // MARK: - Methods
    override func layoutContent() {
        // card imageview
        contentView.addSubview(cardImageView)
        cardImageView.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 10)
        cardImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        cardImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        cardImageView.autoSetDimension(.height, toSize: size.width * 200 / 345)
        
        // dim card image
        let maskView = UIView(forAutoLayout: ())
        maskView.cornerRadius = 10
        maskView.backgroundColor = .black
        maskView.alpha = 0.4
        cardImageView.addSubview(maskView)
        maskView.autoPinEdge(.top, to: .top, of: cardImageView)
        maskView.autoPinEdge(.bottom, to: .bottom, of: cardImageView)
        maskView.autoPinEdge(.leading, to: .leading, of: cardImageView)
        maskView.autoPinEdge(.trailing, to: .trailing, of: cardImageView)
        
        let titleButtonContainerView = UIView(forAutoLayout: ())
        titleButtonContainerView.backgroundColor = .clear
        contentView.addSubview(titleButtonContainerView)
        
        titleButtonContainerView.autoAlignAxis(.horizontal, toSameAxisOf: cardImageView)
        titleButtonContainerView.autoAlignAxis(.vertical, toSameAxisOf: cardImageView)
        titleButtonContainerView.autoPinEdge(.leading, to: .leading, of: cardImageView, withOffset: 16)
        titleButtonContainerView.autoPinEdge(.trailing, to: .trailing, of: cardImageView, withOffset: -16)
        
        titleButtonContainerView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        titleButtonContainerView.addSubview(readButton)
        readButton.autoAlignAxis(toSuperviewAxis: .vertical)
        readButton.autoPinEdge(toSuperviewEdge: .bottom)
        
        readButton.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        
        // pin content bottom
        cardImageView.autoPinEdge(.bottom, to: .top, of: voteContainerView, withOffset: -10)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        super.setUp(with: post)
        cardImageView.image = UIImage(named: "article-placeholder")

        titleLabel.text = post.document?.attributes?.title

        if let coverString = post.document?.attributes?.coverUrl,
            let coverURL = URL(string: coverString) {
            cardImageView.sd_setImageCachedError(with: coverURL, completion: nil)
        }
    }
}
