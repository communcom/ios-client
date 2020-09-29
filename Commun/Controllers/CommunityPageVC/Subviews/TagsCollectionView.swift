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
            contentView.backgroundColor = .appWhiteColor
            contentView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
            contentView.addSubview(label)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
