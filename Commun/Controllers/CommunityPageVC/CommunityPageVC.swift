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
    private let disposeBag = DisposeBag()
    
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
    
    var headerView: CommunityHeaderView!
    
    private lazy var tableView: UITableView = {
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
        view.backgroundColor = .white
        
        view.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset = UIEdgeInsets(top: coverHeight - 24, left: 0, bottom: 0, right: 0)
        
        headerView = CommunityHeaderView(tableView: tableView)
        headerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
        
        view.bringSubviewToFront(backButton)
        
        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
    }
    
    override func bind() {
        super.bind()
        #warning("retry button")
//        let retryButton = UIButton(forAutoLayout: ())
//        retryButton.setTitleColor(.gray, for: .normal)
        // bind state
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?.view.showLoading()
                case .finished:
                    self?.view.hideLoading()
                case .error(let error):
                    self?.showError(error)
                    self?.back()
                }
            })
            .disposed(by: disposeBag)
        
        // list loading state
        #warning("list loading state")
        
        // bind content
        viewModel.community
            .filter {$0 != nil}
            .map {$0!}
            .do(onNext: { (_) in
                self.headerView.selectedIndex.accept(0)
            })
            .subscribe(onNext: { [weak self] (community) in
                self?.setUpWithCommunity(community)
            })
            .disposed(by: disposeBag)
        
        // bind tableview
        let items = viewModel.items
        
        items
            .bind(to: tableView.rx.items) {table, index, element in
                guard let element = element else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
                    #warning("fix later")
                    cell.setUp(with: .posts)
                    return cell
                }
                
                if index == self.tableView.numberOfRows(inSection: 0) - 2 {
                    self.viewModel.fetchNext()
                }
                
                if let post = element as? ResponseAPIContentGetPost {
                    switch post.document.attributes?.type {
                    case "article":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                        cell.setUp(with: post)
                        return cell
                    case "basic":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                        cell.setUp(with: post)
                        return cell
                    default:
                        return UITableViewCell()
                    }
                }
                
                fatalError("Unknown cell type")
            }
            .disposed(by: disposeBag)
        
        
        // Bind segmentedItem
        headerView.selectedIndex
            .map { index -> CommunityPageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .leads
                case 2:
                    return .about
                case 3:
                    return .rules
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
            
    }
    
    func setUpWithCommunity(_ community: ResponseAPIContentGetCommunity) {
        // cover
        if let urlString = community.coverUrl,
            let url = URL(string: urlString)
        {
            coverImageView.sd_setImage(with: url, completed: nil)
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
