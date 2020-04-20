//
//  CommunityMembersHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CommunityMembersHeaderView: MyView {
    // height = 268
    lazy var leadersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.autoSetDimension(.height, toSize: 166)
        return collectionView
    }()
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appLightGrayColor
        let label = UILabel.with(text: "leaders".localized().uppercaseFirst, textSize: 20, weight: .bold)
        addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        label.autoPinEdge(toSuperviewEdge: .leading)
        
        leadersCollectionView.register(LeaderFollowCollectionCell.self, forCellWithReuseIdentifier: "LeaderFollowCollectionCell")
        addSubview(leadersCollectionView)
        leadersCollectionView.autoPinEdge(.top, to: .bottom, of: label, withOffset: 16)
        leadersCollectionView.autoPinEdge(toSuperviewEdge: .leading)
        leadersCollectionView.autoPinEdge(toSuperviewEdge: .trailing)

        let label2 = UILabel.with(text: "members".localized().uppercaseFirst, textSize: 20, weight: .bold)
        addSubview(label2)
        label2.autoPinEdge(.top, to: .bottom, of: leadersCollectionView, withOffset: 20)
        label2.autoPinEdge(toSuperviewEdge: .leading)
        label2.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
}
