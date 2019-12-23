//
//  UICollectionView+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 12/20/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UICollectionView {
    static func horizontalFlow<T: UICollectionViewCell>(cellType: T.Type, height: CGFloat, contentInsets: UIEdgeInsets? = nil, backgroundColor: UIColor = .clear) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.autoSetDimension(.height, toSize: height)
//        collectionView.layer.masksToBounds = false
        
        collectionView.register(T.self, forCellWithReuseIdentifier: "\(T.self)")
        
        if let insets = contentInsets {
            collectionView.contentInset = insets
        }
        
        collectionView.backgroundColor = backgroundColor
        return collectionView
    }
}
