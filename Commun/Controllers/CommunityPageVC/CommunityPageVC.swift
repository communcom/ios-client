//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityPageVC: BaseViewController {
    // MARK: - Properties
    let communityId: String
    let coverHeight: CGFloat = 180
    
    // MARK: - Subviews
    lazy var backButton: UIButton = {
        let button = UIButton(width: 24, height: 40, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 12))
        button.tintColor = .white
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: coverHeight)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        return scrollView
    }()
    
    
    lazy var headerView: CommunityHeaderView = {
        let headerView = CommunityHeaderView(forAutoLayout: ())
        return headerView
    }()
    
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .white
        
        view.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        scrollView.contentInset = UIEdgeInsets(top: coverHeight - 24, left: 0, bottom: 0, right: 0)
        
        scrollView.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        headerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    override func bind() {
        super.bind()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class CommunityPagePostsVC: PostsViewController {
    let communityId: String
    
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // assign tableView
        view.addSubview(tableView)
//        tableView.insetsContentViewsToSafeArea = false
//        tableView.contentInsetAdjustmentBehavior = .never
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.insetsContentViewsToSafeArea = false
    }
    
    override func setUpViewModel() {
        viewModel = PostsViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: communityId))
    }
}
