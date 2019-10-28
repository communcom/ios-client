//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommunityPageVC: BaseViewController {
    override var contentScrollView: UIScrollView? {tableView}
    
    // MARK: - Properties
    let communityId: String
    let coverHeight: CGFloat = 180
    lazy var viewModel: CommunityPageViewModel = CommunityPageViewModel(communityId: communityId)
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var backButton: UIButton = .back(tintColor: .white)
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: coverHeight)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    var headerView: CommunityHeaderView!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    // MARK: - Initializers
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9605136514, green: 0.9644123912, blue: 0.9850376248, alpha: 1)
        navigationItem.backBarButtonItem?.title = " "
        
        view.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 4)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset = UIEdgeInsets(top: coverHeight - 24, left: 0, bottom: 0, right: 0)
        
        headerView = CommunityHeaderView(tableView: tableView)
        headerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
        
        view.bringSubviewToFront(backButton)
        
        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        tableView.register(CommunityLeaderCell.self, forCellReuseIdentifier: "CommunityLeaderCell")
        tableView.register(CommunityAboutCell.self, forCellReuseIdentifier: "CommunityAboutCell")
        
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
        bindCommunity()
        
        bindList()
        
        bindControls()
    }
    
    func setUpWithCommunity(_ community: ResponseAPIContentGetCommunity) {
        // title
        title = community.name
        
        // cover
        if let urlString = community.coverUrl
        {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        headerView.setUp(with: community)
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
