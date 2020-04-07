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
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(forAutoLayout: ())
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "search".localized().uppercaseFirst
        return searchBar
    }()
    
    lazy var nextButton = CommunButton.circle(size: 50, backgroundColor: .appMainColor, tintColor: .white, imageName: nextButtonImageName, imageEdgeInsets: UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7))
    
    lazy var communitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        
        let width = view.width - 32
        let horizontalSpacing: CGFloat = 16 * Config.heightRatio
        let itemWidth = (width - horizontalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 190)
        
        layout.headerReferenceSize = CGSize(width: width, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.configureForAutoLayout()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarHeight, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        collectionView.register(FTUECommunityCell.self, forCellWithReuseIdentifier: "CommunityCollectionCell")
        collectionView.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: FTUECommunitiesHeaderView.self)
        
        // collection view
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        collectionView.addSubview(refreshControl)
        refreshControl.tintColor = .appGrayColor
        refreshControl.subviews.first?.bounds.origin.y = 15

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
        AnalyticsManger.shared.successfulRegistration()
        
        // collectionView
        view.addSubview(communitiesCollectionView)
        communitiesCollectionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        
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
        // do nothing
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
