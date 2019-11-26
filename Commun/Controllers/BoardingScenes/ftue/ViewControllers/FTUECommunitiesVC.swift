//
//  FTUECommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class FTUECommunitiesVC: BaseViewController {
    // MARK: - Constants
    let bottomBarHeight: CGFloat = 114
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    lazy var headerView = UIView(forAutoLayout: ())
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(forAutoLayout: ())
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "search".localized().uppercaseFirst
        return searchBar
    }()
    
    lazy var nextButton = CommunButton.circle(size: 50, backgroundColor: .appMainColor, tintColor: .white, imageName: "next-arrow", imageEdgeInsets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
    
    lazy var communitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    let viewModel = FTUECommunitiesViewModel(type: .all)

    // bottomBar
    private lazy var shadowView = UIView(height: bottomBarHeight)
    lazy var bottomBar = UIView(backgroundColor: .white)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // headerView
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        // titleLabel
        let titleLabel = UILabel.with(text: "get you first points".localized().uppercaseFirst, textSize: 33, weight: .bold, numberOfLines: 0)
        headerView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        // descriptionLabel
        let descriptionLabel = UILabel.with(textSize: 17, textColor: .a5a7bd, numberOfLines: 0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let attrString = NSAttributedString(string: "subscribe to at least 3 communities and get your first Community Points".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = attrString
        headerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // searchBar
        headerView.addSubview(searchBar)
        searchBar.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 25)
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
        
        // collection view
        communitiesCollectionView.register(SubscriptionCommunityCell.self, forCellWithReuseIdentifier: "SubscriptionCommunityCell")
        communitiesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarHeight, right: 0)
        view.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdge(.top, to: .top, of: headerView)
        communitiesCollectionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        
        // bottomBar
        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        shadowView.addShadow(ofColor: .shadow, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)
        
        shadowView.addSubview(bottomBar)
        bottomBar.autoPinEdgesToSuperviewEdges()
        
        bottomBar.addSubview(nextButton)
        nextButton.autoPinTopAndTrailingToSuperView(inset: 20, xInset: 16)
    }
    
    override func bind() {
        super.bind()
        bindControl()
        bindCommunities()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var contentInset = communitiesCollectionView.contentInset
        contentInset.top = headerView.height +  20
        communitiesCollectionView.contentInset = contentInset
        
        shadowView.layoutIfNeeded()
        bottomBar.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 24.5)
    }
}
