//
//  TagsCollectionView.swift
//  Commun
//
//  Created by Chung Tran on 9/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class TagsCollectionView: UICollectionView {
    class TagCell: MyCollectionViewCell {
        lazy var label = UILabel.with(textSize: 12, weight: .bold, textColor: .white, textAlignment: .center)
        override func setUpViews() {
            super.setUpViews()
            contentView.cornerRadius = 10
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = contentView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(blurEffectView)
            
            contentView.addSubview(label)
            label.autoCenterInSuperview()
            label.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -8)
                .isActive = true
        }
    }
    
    init(height: CGFloat) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        configureForAutoLayout()
        autoSetDimension(.height, toSize: height)
        register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        semanticContentAttribute = .forceRightToLeft
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
