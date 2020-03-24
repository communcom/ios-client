//
//  EditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension EditorVC {
    @objc func layoutContentView() {
        
    }
    
    func setUpToolbarButtons() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        buttonsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        buttonsCollectionView.showsHorizontalScrollIndicator = false
        buttonsCollectionView.backgroundColor = .clear
        buttonsCollectionView.configureForAutoLayout()
        toolbar.addSubview(buttonsCollectionView)
        
        // layout
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        buttonsCollectionView.autoSetDimension(.height, toSize: 35)
        
        buttonsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        buttonsCollectionView.register(EditorToolbarItemCell.self, forCellWithReuseIdentifier: "EditorToolbarItemCell")
    }
}
