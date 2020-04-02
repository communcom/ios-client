//
//  FTUECommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class FTUECommunitiesVC: BaseViewController, SearchableViewControllerType {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.embeded}
    
    // MARK: - Constants
    let bottomBarHeight: CGFloat = 114
    let nextButtonImageName = "next-arrow"
    
    // MARK: - Properties
    lazy var headerView = UIView(forAutoLayout: ())
    
    lazy var descriptionLabel = UILabel.with(textSize: 17 * Config.heightRatio, textColor: .a5a7bd, numberOfLines: 0)
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(forAutoLayout: ())
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "search placeholder".localized().uppercaseFirst
        return searchBar
    }()
    
    lazy var nextButton = CommunButton.circle(size: 50, backgroundColor: .appMainColor, tintColor: .white, imageName: nextButtonImageName, imageEdgeInsets: UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7))
    
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
    
    lazy var chosenCommunitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.autoSetDimension(.height, toSize: 50)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let viewModel = FTUECommunitiesViewModel()
    let refreshControl = UIRefreshControl(forAutoLayout: ())

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
        let titleLabel = UILabel.with(text: "get you first points".localized().uppercaseFirst, textSize: 33 * Config.heightRatio, weight: .bold, numberOfLines: 0)
        headerView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        // descriptionLabel
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 * Config.heightRatio
        let attrString = NSAttributedString(string: "subscribe to at least 3 communities".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = attrString
        headerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16 * Config.heightRatio)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // searchBar
        layoutSearchBar()
        
        // collection view
        communitiesCollectionView.keyboardDismissMode = .onDrag
        communitiesCollectionView.isUserInteractionEnabled = true
        communitiesCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        communitiesCollectionView.register(FTUECommunityCell.self, forCellWithReuseIdentifier: "CommunityCollectionCell")
        communitiesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarHeight, right: 0)

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        communitiesCollectionView.addSubview(refreshControl)
        refreshControl.tintColor = .appGrayColor
        refreshControl.subviews.first?.bounds.origin.y = 15

        view.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdge(.top, to: .top, of: headerView)
        communitiesCollectionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        
        view.bringSubviewToFront(headerView)
        
        // bottomBar
        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        shadowView.addShadow(ofColor: .shadow, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)
        
        shadowView.addSubview(bottomBar)
        bottomBar.autoPinEdgesToSuperviewEdges()
        
        bottomBar.addSubview(nextButton)
        nextButton.autoPinTopAndTrailingToSuperView(inset: 20, xInset: 16)
        nextButton.addTarget(self, action: #selector(nextButtonDidTouch), for: .touchUpInside)
        
        bottomBar.addSubview(chosenCommunitiesCollectionView)
        chosenCommunitiesCollectionView.autoPinTopAndLeadingToSuperView(inset: 20, xInset: 0)
        chosenCommunitiesCollectionView.autoPinEdge(.trailing, to: .leading, of: nextButton, withOffset: -10)
        chosenCommunitiesCollectionView.register(FTUEChosenCommunityCell.self, forCellWithReuseIdentifier: "FTUEChosenCommunityCell")
        chosenCommunitiesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }

    @objc func refresh() {
        viewModel.reload()
        refreshControl.endRefreshing()
    }
    
    override func bind() {
        super.bind()
        bindControl()
        bindCommunities()
        bindSearchBar()
        
        observeCommunityFollowed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        communitiesCollectionView.contentInset.top = headerView.height + 20
        
        shadowView.layoutIfNeeded()
        bottomBar.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 24.5)
    }
    
    @objc func nextButtonDidTouch() {
        showIndetermineHudWithMessage("just a moment".localized().uppercaseFirst + "...")
        let ids = viewModel.chosenCommunities.value.map {$0.communityId}
        RestAPIManager.instance.onboardingCommunitySubscriptions(communityIds: ids)
            .subscribe(onCompleted: {
                AnalyticsManger.shared.ftueSubscribe(codes: ids)
                self.hideHud()
                UserDefaults.standard.set(true, forKey: Config.currentUserDidSubscribeToMoreThan3Communities)
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Search
    func layoutSearchBar() {
        headerView.addSubview(searchBar)
        searchBar.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 25 * Config.heightRatio)
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        viewModel.searchVM.query = query
        viewModel.searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.searchVM.query = nil
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
